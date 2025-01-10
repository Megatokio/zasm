#!/usr/local/bin/zasm -x --target=ram -o original/intel-hex-with-gaps.hex




    org    $4000
    defb    $ca

    org    $4010
    defb    $fe

    org    $4020
    defb    $ba

    org    $f000
    defb    $ba
