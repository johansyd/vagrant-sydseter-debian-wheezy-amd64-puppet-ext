#!/usr/bin/perl
use warnings;
use Test::More;
use LWP::UserAgent;
use Test::BDD::Cucumber::StepFile;
use Method::Signatures;
=head1 AUTHOR 

Johan Sydseter, <johan.sydseter@startsiden.no>

=head1 DESCRIPTION

These common steps tests the following features.

Feature: ABCN-2166, https://bugs.startsiden.no/browse/ABCN-2166
The project manager needs to be able to automaticly tests that
new features has been implemented on www.abcnyheter.no, and the users
want to be able to browse different news categories on www.abcnyher.no.
Verify that we have web pages on www.abcnyheter.no and hold a
demonstration for the product owners introducing the BDD acceptance test
concept.

Feature: Verifying the installability of custom built php packages

Feature: Verifying the state of system dependencies

=cut

=head2 Scenario

Check the precence of the main categories

=cut

=head3

When I go to "<category>"

=cut
When qr/I go to "(.+)"/, func ($c) {

    $c->stash->{scenario}->{category} = $1;

    my $category = $c->stash->{scenario}->{category};

    my $config = ABCN::Testsuite->instance->config();

    my $domain = $config->{'baseurl'}; 

    $c->stash->{scenario}->{url} = "http://$domain/$category"; 
};

=head3

Scenario: Check the precence of the main api categories

=cut

=head3 When

I go to api url "<path>"

=cut
When qr/I go to api url "(.+)"/, func ($c) {

    $c->stash->{scenario}->{path} = $1;

    my $category = $c->stash->{scenario}->{path};

    my $config = ABCN::Testsuite->instance->config();

    my $domain = $config->{'api'}; 

    $c->stash->{scenario}->{url} = "http://$domain/$category"; 
};

=head3 Then

I get the http status "<status>"

=cut
Then qr/I get the http status (.+)/, func ($c) {

    my $url = $c->stash->{scenario}->{url};

    $c->stash->{scenario}->{code} = $1;
    my $status_codes = $c->stash->{scenario}->{code};

    my @status_codes = split(/,/, $status_codes);

    my $user_agent = new LWP::UserAgent();
    $user_agent->timeout(10);
    my $response = $user_agent->get($url);
    my $content_type = $response->content_type();;

    my $status_line = $response->status_line();
    $status_line =~ m/[0-9][0-9][0-9]/;

    my $status = $&; 

    my $is_match;
    foreach (@status_codes) {
        $is_match = ( $_ =~ m/$status/)  || 0;
    }

    ok($is_match, "Found the $url to be retrieving $status. "
        . "It Should be retrieving on of these $status_codes");

    $c->stash->{scenario}->{content_type} = $content_type;
};


=head3 Then

I recieve content "<type>"

=cut
Then qr/I recieve content (.+)/, func ($c) {
   my $type = $1;
   my $found_content_type = $c->stash->{scenario}->{content_type};

   ok(($type =~ m/$found_content_type/), "Check that ${type} is similar to ${found_content_type}");
 
};

=head2 Scenario

Verify that a custom built php package can be installed

=cut

=head3 When

the "<path>" exist

=cut
When qr/the "(.+)" exist/, func ($c) {
    my $dir = $1;
    my $status = 0;


    if(-d $dir) {
        $status = 1;
    }

    $c->stash->{scenario}->{installable} = $status;

    ok($status, "Whether ${dir} exist.");
};


=head3 And

the PHP API Version is "<api_version>"

=cut
When qr/the PHP API Version is "(.+)"/, func ($c) {
  my $api_versions = $1;
  my @php_api_versions = split(/,/, $api_versions);

  my $version = qx(phpize5 --version | head -n 2 | tail -n -1 | tr -d ' ' | cut -d':' -f2);
  chomp($version);

  my $is_match;
  foreach (@php_api_versions) {
      $is_match = ( $_ =~ m/$version/ ) || 0;
  }

  ok($is_match, "The PHP API Version has to be ${api_versions} but was ${version}.");

};

=head3 Then

the "<package>" should be installable

=cut

Then qr/the "(.+)" should be installable/, func ($c) {

    my $package = $1;
    my $is_installable = $c->stash->{scenario}->{installable};

    ok($is_installable, "${package} can not be installed");
};




=head2 Scenario

Verify the state of php modules

=cut

=head3 When

"<package>" is installed with one of these php api "<keys>"

=cut
When qr/ "(.+)" is installed with one of these php api "(.+)"/, func ($c) {
    my $package = $1;
    my $api_keys = $2;

    my @php_api_versions = split(/,/, $api_keys);

    my $version = qx(phpize5 --version | head -n 2 | tail -n -1 | tr -d ' ' | cut -d':' -f2);

    chomp($version);

    my $is_match;
    foreach (@php_api_versions) {
        $is_match = ( $_ =~ m/$version/ ) || 0;
    }

    ok($is_match, "The PHP API Version has to be ${api_versions} but was ${version}.");

};

=head3 And

the php support for "<module>" is "<status>"

=cut
When qr/the php support "(.+)" is "(.+)"/, func ($c) {
    my $module = $1;
    my $status = $2;

};

=head3 Then

the "<class>" can be instantiated

=cut
Then qr/the "(.+)" can be instantiated/, func ($c) {

    $class = $1;
    $is_installed = qx(php -r '$config=array("application" => array("directory" => dirname("./"),"dispatcher" => array("catchException" => 1),"view" => array("ext" => "phtml"))); $app = new '${class}'($config);');
};

1;

