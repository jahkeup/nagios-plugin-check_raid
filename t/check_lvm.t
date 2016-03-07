#!/usr/bin/perl
BEGIN {
	(my $srcdir = $0) =~ s,/[^/]+$,/,;
	unshift @INC, $srcdir;
}

use strict;
use warnings;
use constant TESTS => 1;
use Test::More tests => 1 + TESTS * 6;
use test;

my @tests = (
	{
		dmsetup => 'pr-134/dmsetup',
		status => OK,
		message => 'vg1-cache:idle, vg1-zoom:idle',
	},
);

# test that plugin can be created
ok(lvm->new, "plugin created");

foreach my $test (@tests) {
	my $plugin = lvm->new(
		commands => {
			'dmsetup' => ['<', TESTDIR . '/data/lvm/' .$test->{dmsetup} ],
		},
	);
	ok($plugin, "plugin created");

	$plugin->check;
	ok(1, "check ran");

	ok(defined($plugin->status), "status code set");
	is($plugin->status, $test->{status}, "status code matches");
	is($plugin->message, $test->{message}, "status message");

	my $c = $plugin->parse;
	my $df = TESTDIR . '/dump/lvm/' . $test->{dmsetup};
	if (!-f $df) {
		store_dump $df, $c;
		# trigger error so that we don't have feeling all is ok ;)
		ok(0, "Created dump for $df");
	}
	my $dump = read_dump($df);
	is_deeply($c, $dump, "parsed structure");
}
