#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use LWP::Simple;
use Data::Dumper;
#use Link::Extor;
use HTML::SimpleLinkExtor;
use URI;

my @all_urls;       # top100 urls
my @all_domains;    # top100 domains
my $urls = undef;   # urls from top100 pages

open FH, "< a1.txt";
@all_domains = <FH>;
close FH;
chomp for @all_domains;

open FH, "< a.txt";
@all_urls = <FH>;
close FH;
chomp for @all_urls;

foreach my $row (@all_urls) {
    my (undef ,$url) = split "\t", $row;
    my $u = URI->new($url);
    my $normalize_url = $u->scheme . "://" . $u->host;

    print $url . "\n";

    my $html = get $url;
    next unless $html;

    my $extor = HTML::SimpleLinkExtor->new();
    $extor->parse($html);
    my @links = $extor->schemes('https', 'http');

    foreach my $link (@links) {
        #print "--\n";
        #print "$_\n";
        my $u = URI->new($link);
        #print "scheme:" . $u->scheme . "\n";
        #print "opaque:" . $u->opaque . "\n";
        #print "path:" . $u->path . "\n";
        #print "fragment:" .$u->fragment . "\n" if defined $u->fragment;
        #print "as_string:" .$u->as_string . "\n";
        #print "canonical:" .$u->canonical . "\n";
        #print "authority:" .$u->authority . "\n";
        #print "userinfo:" .$u->userinfo . "\n" if defined $u->userinfo;
        #print "host:" .$u->host . "\n";
        next if ($u->path =~ /\.((js)|(css)|(jpg)|(gif)|(rdf)|(xml)|(ico)|(rss)|(pdf))$/i); 
        #print $u->path . "\n";
        #$u->path =~ /.*\.(.*)$/;
        #$ext->{$1} = $u->path if defined $1;
        my $domain = $u->scheme . "://" . $u->host;
        next if ($domain eq $normalize_url);
        $urls->{$normalize_url} = $domain;
        print " $domain\n";
    }
}

open FH, ">>a2.txt";
foreach my $url (keys %{$urls}) {
    print $url . "\t" . $urls->{$url} . "\n";
    print FH $url . "\t" . $urls->{$url} . "\n";
}
close FH;
=pod
exit;

chomp;
#print "> $_\n";

my (undef ,$url) = split "\t", $_;
#print "$url\n";

my $normalize_url;
my $u = URI->new($url);
if ($u->scheme =~ /http(s)?/) {
    $normalize_url = $u->scheme . "://" . $u->host if defined $u->host;
}

my $urls = undef;

my $html = get $url;

my $extor = HTML::SimpleLinkExtor->new();
$extor->parse($html);
#print "--links\n";
#my @all_links   = $extor->links;
#print Dumper(@all_links);
#print "--a\n";
#my @a_hrefs   = $extor->a;
#print Dumper(@a_hrefs);
#print "--absolute_links\n";
#my @hrefs   = $extor->href;
#print Dumper(@hrefs);
#print "--scheme\n";
#my @schemes = $extor->schemes('http', 'https');
#print Dumper(@schemes);
#print "--absolute_links\n";
#my @absolute_links = $extor->absolute_links;
#print Dumper(@absolute_links);
#print "$_\n" for @absolute_links;
#print "---\n";
my @links = $extor->schemes('https', 'http');

my $ext;
for (@links) {
    #print "--\n";
    #print "$_\n";
    my $u = URI->new($_);
    #print "scheme:" . $u->scheme . "\n";
    #print "opaque:" . $u->opaque . "\n";
    #print "path:" . $u->path . "\n";
    #print "fragment:" .$u->fragment . "\n" if defined $u->fragment;
    #print "as_string:" .$u->as_string . "\n";
    #print "canonical:" .$u->canonical . "\n";
    #print "authority:" .$u->authority . "\n";
    #print "userinfo:" .$u->userinfo . "\n" if defined $u->userinfo;
    #print "host:" .$u->host . "\n";
    next if ($u->path =~ /\.((js)|(css)|(jpg)|(gif)|(rdf)|(xml)|(ico)|(rss)|(pdf))$/i); 

    #print $u->path . "\n";
    #$u->path =~ /.*\.(.*)$/;
    #$ext->{$1} = $u->path if defined $1;

    my $domain = $u->scheme . "://" . $u->host if defined $u->host;

    next if ($domain eq $normalize_url);
    $urls->{$domain} = $domain;
    #print "$domain\n";
}
#print "$_\n" for keys %{$ext};

if (ref $urls) {
    open FH, ">>a2.txt";
    foreach (sort keys %{$urls}) {
        unless ($_ eq $normalize_url) {
            print "$normalize_url\t$_\n";
            print FH "$normalize_url\t$_\n";
        }
    }
    close FH;
    #print "$_\n" for sort keys %{$urls};
}
=cut
