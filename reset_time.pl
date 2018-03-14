#! /usr/bin/perl -w
use strict;
use POSIX;

# use ...
# This is very important !
use vars qw(%RAD_CHECK);
use constant RLM_MODULE_OK=> 2;# /* the module is OK,
continue */
use constant RLM_MODULE_NOOP=> 7;
use constant RLM_MODULE_UPDATED=> 8;# /* OK (pairs modified) */

sub authorize {
    #Find out when the reset time should be
    if($RAD_CHECK{'FRBG-Reset-Type'} =~ /monthly/i){
        $RAD_CHECK{'FRBG-Start-Time'} = start_of_month()
    }
    if($RAD_CHECK{'FRBG-Reset-Type'} =~ /weekly/i){
        $RAD_CHECK{'FRBG-Start-Time'} = start_of_week()
    }
    if($RAD_CHECK{'FRBG-Reset-Type'} =~ /daily/i){
        $RAD_CHECK{'FRBG-Start-Time'} = start_of_day()
    }
    if(exists($RAD_CHECK{'FRBG-Start-Time'})){
        return RLM_MODULE_UPDATED;
    }else{
        return RLM_MODULE_NOOP;
    }
}

sub start_of_month {
    #Get the current timestamp;
    my $reset_on = 1;
    #you decide when the monthly CAP will reset
    my $unixtime;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    if($mday < $reset_on ){
        $unixtime = mktime (0, 0, 0, $reset_on, $mon-1, $year, 0, 0); #We use the previous month
    }else{
        $unixtime = mktime (0, 0, 0, $reset_on, $mon, $year, 0, 0); #We use this month
    }
    return $unixtime;
}

sub start_of_week {
    #Get the current timestamp;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    #create a new timestamp:
    my $unixtime = mktime (0, 0, 0, $mday-$wday, $mon, $year, 0, 0);
    return $unixtime;
}

sub start_of_day {
    #Get the current timestamp;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    #create a new timestamp:
    my $unixtime = mktime (0, 0, 0, $mday, $mon, $year, 0, 0);
    return $unixtime;
}
