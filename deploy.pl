#!/usr/bin/perl

use warnings;
use strict;
use 5.010;
use utf8;

use Getopt::Long;
use Eixo::Docker::Api;
use JSON;

my ($image_id, $publish, $name, $endpoint);
my @cmd;

GetOptions('image=s'    => \$image_id,
           'publish=s'  => \$publish,
           'name=s'     => \$name,
           'cmd=s'      => \@cmd,
           'endpoint=s' => \$endpoint)
or die 'Error in command line arguments';

foreach ($image_id, $endpoint) {
  die 'Usage: perl deploy.pl --image <image> --endpoint <endpoint> [--publish <publish>] [--name <name>] [--cmd <cmd> [--cmd <cmd>] ...]'
    unless defined $_ and length $_;
}

my $portBindings = {};
my $exposedPorts = {};

if ($publish) {
  die 'Bad publish argument. Example: 8080:9090'
    unless $publish =~ /^(\d+)\:(\d+)$/;

  $exposedPorts->{$1} = {};
  $portBindings->{$1} = [ { HostPort => $2 } ];
}

my ($repo, $image_name, $tag) = split /[\/:]/, $image_id;

eval {
  my $docker = Eixo::Docker::Api->new($endpoint);

  my $image = $docker->images->create(
    fromImage => "$repo/$image_name",
    tag       => $tag
  );

  my $container = $docker->containers->create(
    Image           => $image_id,
    Name            => $name,
    Cmd             => \@cmd,
    NetworkDisabled => \0,
    ExposedPorts    => $exposedPorts,

    HostConfig      => {
      PortBindings  => $portBindings
    }
  );

  $container->start();

  say 'Container started with ID ' . $container->{Id};
};

die docker_error() if $@;


sub docker_error {
  my $error = 'Error Code ' . $@->args->[0] . '. ';

  $error .= decode_json($@->args->[1])->{message}
    if $@->args->[1];
}