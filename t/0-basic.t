#!/usr/bin/env perl

use strict;
use Test::More tests => 13;

use_ok('WWW::Scraper::ISBN::TWCwbook_Driver');

ok($WWW::Scraper::ISBN::TWCwbook_Driver::VERSION) if $WWW::Scraper::ISBN::TWCwbook_Driver::VERSION or 1;

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

$scraper->drivers("TWCwbook");
my $isbn = "9867158156";
my $record = $scraper->search($isbn);

SKIP: {
	skip($record->error."\n", 10) unless($record->found);

	is($record->found, 1);
	is($record->found_in, 'TWCwbook');

	my $book = $record->book;
	is($book->{'isbn'}, '9867158156');
	is($book->{'title'}, '�y������');
	is($book->{'author'}, '�w�}�E�ʹ���');
	is($book->{'book_link'}, 'http://www.cwbook.com.tw/cw/TD.jsp?pid=BCCF0093P');
	is($book->{'image_link'}, 'http://www.cwbook.com.tw/cw/images/cover/BBCCF0093P.jpg');
	is($book->{'pubdate'}, '2005/10/26');
	is($book->{'publisher'}, '�ѤU���x');
	is($book->{'price_list'}, '320');
}
