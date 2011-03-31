#!/usr/bin/perl -w

sub indexArray($@)
{
 my $s=shift;
 $_ eq $s && return @_ while $_=pop;
 -1;
}

