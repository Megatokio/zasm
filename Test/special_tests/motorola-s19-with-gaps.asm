#!/usr/local/bin/zasm -s --target=ram  --date='2020-4-12 0:00' -o original/



    org    $4000
    defb    $ca

    org    $4010
    defb    $fe

    org    $4020
    defb    $ba

    org    $f000
    defb    $ba
