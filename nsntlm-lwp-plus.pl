#
# Modified script based on nsntlm-lwp.pl script provided by Citrix
#
# Argument LIST - *Don't change the order of arguments.
## -> The mandatory arguments are:
##      1. url          => URL to be accessed. Give the path only RL e.g. -> url=/a.b.c.d/ntlm/file51.html;
##      2. user         => User Name, e.g. -> user name to be used for authentication e.g. -> user=<USER>; or <DOMAIN>\<USER>;
##      3. password     => This is the password that will be used to login into the server e.g. -> password=<password>
## -> The optional arguments are:
#       4. realm        => realm for the server. For testing purpose you can set it to null. Based on realm a differnt context is set on client.
#                 e.g. -> realm=''; relam=<realm>;
#       5. version:     => ntlm version to be used. if it is 2, ntlmv2 will be used. default ntlmv1
#
#       6. ssl:         => if https should be used, configure ssl=1
#
#       7. match:       => string to be matched, match=OK
#
## The arguments must be of the following form:
##      url=<url>;user=<username>[;password=<password>][domain=<domain>][realm=<realm>][version=<NTLM version to be used. default '1'>][ssl=<if https should be used. default '0''][match=<string>]
## Examples:
##      set monitor ...  -scriptArgs url='http://a.b.c.d/ntlm/file51.html';user=user1;password=password;domain=<domain>;realm='';version=2"
##      set monitor ...  -scriptArgs url='http://a.b.c.d/ntlm/file51.html';user=domain\user1;password=password;"

use strict;
use LWP::UserAgent;
#use Authen::NTLM;
use HTTP::Request::Common;
use CGI;




#print "Test";






# my $postpar='nsumon_ip=1.2.3.4&nsumon_port=8080&nsumon_args=url=/alive.aspx;user=xxx;password=yyyy;match=OK';


#my $postpar=$ARGV[0];

my $q = CGI->new;
my $postpar=$q->param( 'POSTDATA' );


#print "HTTP/1.0 200 OK";
#print "\n";
#print "Content-Type: text/html";
#print $ARGV[0];

#print $postpar;
#print "\n";

my $netloc='';
my $realm='';
my $username='';
my $password='';
my $searchstring='';
my $url='';
my $version=1;
my $secure=0;
my $protocol='http';


## Parse the argument given, to get url,realm, use name,password, ntlm version.
## If parsing fails, it is monitoring probe failure.


if (!($postpar=~/nsumon_ip=([^;]+)&nsumon_port=([^;]+)&nsumon_args=(.+)/)) {
                  print "HTTP/1.0 404 Not Found 1";
                 exit 1;
}

my $targetip=$1;
my $targetport=$2;
my $args=$3;

#print $targetip;
#print "\n";
#print $targetport;
#print "\n";
#print $args;
#print "\n";

## Parse the argument given, to get url,realm, use name,password, ntlm version.
## If parsing fails, it is monitoring probe failure.

#$args=~/url=([^;]+);user=([^;]+)(;password=([^;]+)?)?(;domain=([^;]+)?)?(;realm=([^;]+)?)?(;version=([^;]+))?;?/
if (!($args=~/url=([^;]+);user=([^;]+)(;password=([^;]+)?)?(;realm=([^;]+)?)?(;version=([^;]+)?)?(;ssl=([^;]+))?(;match=([^;]+))?;?/)) {
                print "HTTP/1.0 404 Not Found 2";
                exit 1;
}

$url=$1;
$username=$2;

if (defined $4) { $password = $4;}
if (defined $6) { $realm = $6;}
if (defined $8) { $version = $8;}
if (defined $10) { $secure = $10;}
if (defined $12) { $searchstring = $12;}


#print $url;
#print "\n";
#print $username;
#print "\n";
#print $password;
#print "\n";
#print $realm;
#print "\n";
#print $version;
#print "\n";
#print $searchstring;
#print "\n";

if (2 == $version) {
        ntlmv2(1);
}

if (1 == $secure) {
        $protocol='https';
}

my $ua = LWP::UserAgent->new(
    ssl_opts => { verify_hostname => 0},
    protocols_allowed => ['http','https'],
    keep_alive=>1
);
$ua->timeout("10");
$netloc = "$targetip".":"."$targetport";
$ua->credentials($netloc, $realm, $username, $password);

my $wholeurl="$protocol"."://"."$targetip".":"."$targetport"."$url";

#print $wholeurl;
#print "\n";

my $request = GET $wholeurl;
my $response = $ua->request($request);
my $body = $response->content;
#print $response->status_line;
#print "\n";
#print $body;

if (!(index($body, $searchstring) > -1)) {
     print "HTTP/1.0 404 Not Found";
     exit 1;
}


#my $cache = $ua->conn_cache();
#$cache->drop();

print <<ENDOFTEXT;
HTTP/1.0 200 OK
Content-Type: text/html

<HTML>
<HEAD><TITLE>Hello World!</TITLE></HEAD>
<BODY>
<H4>Hello World!</H4>
<H5>Have a nice day!</H5>
</BODY>
</HTML>
ENDOFTEXT


exit(0);







