#! usr/bin/perl -w
use strict;
# use ...
# This is very important!

use vars qw(%RAD_CHECK %RAD_REPLY);
use constant RLM_MODULE_OK=> 2;# /* the module is OK, continue */
use constant RLM_MODULE_UPDATED=> 8;# /* OK (pairs modified) */
use constant RLM_MODULE_REJECT=> 0;# /* immediately reject the request */
use constant RLM_MODULE_NOOP=> 7;

my $int_max = 4294967296;
sub authorize {
    #We will reply, depending on the usage
    #If FRBG-Total-Bytes is larger than the 32-bit limit we have to set a Gigaword attribute
    if(exists($RAD_CHECK{'FRBG-Total-Bytes'}) && exists($RAD_CHECK{'FRBG-Used-Bytes'})){
        $RAD_CHECK{'FRBG-Avail-Bytes'} = $RAD_CHECK{'FRBG-Total-Bytes'} - $RAD_CHECK{'FRBG-Used-Bytes'};
    }else{
        return RLM_MODULE_NOOP;
    }
    if($RAD_CHECK{'FRBG-Avail-Bytes'} <= $RAD_CHECK{'FRBG-Used-Bytes'}){
        if($RAD_CHECK{'FRBG-Reset-Type'} ne 'never'){
            $RAD_REPLY{'Reply-Message'} = "Maximum $RAD_CHECK{'FRBG-Reset-Type'} usage exceeded";
        }else{
            $RAD_REPLY{'Reply-Message'} = "Maximum usage exceeded";
        }
        return RLM_MODULE_REJECT;
     }
    if($RAD_CHECK{'FRBG-Avail-Bytes'} >= $int_max){
        #Mikrotik's reply attributes
        $RAD_REPLY{'Mikrotik-Total-Limit'} = $RAD_CHECK{'FRBG-Avail-Bytes'} % $int_max;
        $RAD_REPLY{'Mikrotik-Total-Limit-Gigawords'} = int($RAD_CHECK{'FRBG-Avail-Bytes'} / $int_max );
        #Coova Chilli's reply attributes
        $RAD_REPLY{'ChilliSpot-Max-Total-Octets'} = $RAD_CHECK{'FRBG-Avail-Bytes'} % $int_max;
        $RAD_REPLY{'ChilliSpot-Max-Total-Gigawords'} = int($RAD_CHECK{'FRBG-Avail-Bytes'} / $int_max );
    }else{
        $RAD_REPLY{'Mikrotik-Total-Limit'} = $RAD_CHECK{'FRBG-Avail-Bytes'};
        $RAD_REPLY{'ChilliSpot-Max-Total-Octets'} = $RAD_CHECK{'FRBG-Avail-Bytes'};
    }
    return RLM_MODULE_UPDATED;
}
