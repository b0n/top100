#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use LWP::Simple;
use XML::Simple;
use URI::Escape;
use Data::Dumper;
use URI;

# http://developer.yahoo.co.jp/webapi/search/websearch/v1/websearch.html
# http://hole.sugutsukaeru.jp/archives/8

# yahoo search api
# site サイトを指定して検索できる site=www.yahoo.co.jp&site=www.asahi.com

# yahoo link:
# http://help.yahoo.co.jp/help/jp/search/search-08.html


my $keyword = shift @ARGV;
die "キーワードを指定してください" unless defined $keyword;
my $escaped_keyword = uri_escape($keyword);

our %param = (
    results => 100,
    start => 1,
);
my @param = map{ "$_=$param{$_}"; } keys %param;
my $param = join "&", @param;

my $apikey = "ieh982uxg66DBTVVVz6tSiC06JudM3fFIcKot9dLiTxIn15CaIWjq.i6bAOO1qHydaODgq66zJqlEA--";
our $url = "http://search.yahooapis.jp/WebSearchService/V1/webSearch?appid=$apikey&query=$escaped_keyword&results=$param{results}";
our $limit = 100;

our $urls;
our @url_arr;
our @domains;
getdata(1);

open FH, "> a.txt";
foreach (@url_arr) {
    print $urls->{$_} . "\t" . $_ . "\n";
    print FH $urls->{$_} . "\t" . $_ . "\n";
}
close FH;

open FH, "> a1.txt";
print FH "$_\n" for @domains;
close FH;

sub getdata {
    my ($start) = @_;

    my $_url = $url . "&start=$start";

    #print "-" x 3 . "\n";
    print "$_url\n";
    #print "-" x 3 . "\n";

    my $xml = get $_url;
    #print $xml;

    my $xs = new XML::Simple();
    my $ref = $xs->XMLin($xml);
    #print Dumper($ref);

    #print $ref->{Result}[0]->{Title} . "\n";

    #my $num = 0;
    for my $result (@{$ref->{Result}}) {
        #print $result->{Title} . "\t" . $result->{Url} . "\n";

        my $u = URI->new($result->{Url});
        next if ($u->path =~ /\.((js)|(css)|(jpg)|(gif)|(rdf)|(xml)|(ico)|(rss)|(pdf))$/i); 

        my $domain = $u->scheme . "://" . $u->host if defined $u->host;
        push @domains, $domain unless ( scalar grep {/^$domain$/} @domains );

        $urls->{$result->{Url}} = $result->{Title};
        push @url_arr, $result->{Url};

        #print "$num:" . $result->{Title} . $result->{Url} . "\n";
        #$num++;
    }

    #print "total: $ref->{totalResultsAvailable}\n";
    #print "get: $ref->{totalResultsReturned}\n";
    #print "first: $ref->{firstResultPosition}\n";
    #print "pgr: $ref->{pgr}\n";

    my $last = $ref->{firstResultPosition} + $ref->{totalResultsReturned} -1;

    #print "last: $last\n";

    if ($ref->{totalResultsReturned} >= $param{results} && $last < $limit) {
        #sleep 1;
        getdata($start+$param{results});
    #} else {
        #print Dumper($ref);
    }
}
