# ex:ts=8

package WWW::Scraper::ISBN::TWCwbook_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.01';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::TWCwbook_Driver - Search driver for TWCwbook's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the TWCwbook's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;

use Data::Dumper;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	CWBOOK	=> "http://www.cwbook.com.tw/cw/T1.jsp";

#--------------------------------------------------------------------------

###########################################################################
#Inheritence                                                              #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Cwbook 
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  title
  author
  book_link
  image_link
  pubdate
  publisher
  price_list
  price_sell

The book_link and image_link refer back to the Cwbook website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
	$mechanize->get(CWBOOK);
	return undef unless($mechanize->success());

	$mechanize->submit_form(
		form_name	=> 'schForm',
		fields		=> {
			schType	=> 'product.isbn',
			schStr	=> $isbn,
		},
	);

	# The Search Results page
	my $template = <<END;
搜尋結果如下：[% ... %]<a href="[% book %]"
END

	my $extract = Template::Extract->new;
	my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from TWCwbook result page.")
		unless(defined $data);

	my $book = $data->{book};
	$mechanize->get($book);

	$template = <<END;
<font color="#0066CC" class="book1">[% title %]</font>[% ... %]
<img class="imagebordercolor" border="1" src="[% image_link %]">[% ... %]
作者：[% ... %] color="#0066CC">[% author %]</font>[% ... %]
出版社：[% ... %] color="#0066CC">[% publisher %]</font>[% ... %]
初版：[% ... %] color="#0066CC">[% pubdate %]</font>[% ... %]
ISBN：[% ... %] color="#0066CC">[% isbn %]</font>[% ... %]
定價：[% ... %]<b>[% price_list %]</b>[% ... %]
優惠價：[% ... %]<b>[% price_sell %]</b>
END

	$data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from TWCwbook result page.")
		unless(defined $data);

	$data->{pubdate} =~ s/\s+//g;

	my $bk = {
		'isbn'		=> $data->{isbn},
		'title'		=> $data->{title},
		'author'	=> $data->{author},
		'book_link'	=> "http://www.cwbook.com.tw".$book,
		'image_link'	=> "http://www.cwbook.com.tw".$data->{image_link},
		'pubdate'	=> $data->{pubdate},
		'publisher'	=> $data->{publisher},
		'price_list'	=> $data->{price_list},
		'price_sell'	=> $data->{price_sell},
	};

	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

=head1 COPYRIGHT

Copyright (C) 2005 Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
