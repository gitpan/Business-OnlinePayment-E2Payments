package Business::OnlinePayment::E2Payments;

use strict;
use Carp;
use Business::OnlinePayment;
use Business::CreditCard;
use Net::SSLeay qw( make_form post_https get_https );
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $DEBUG);

require Exporter;

@ISA = qw(Exporter AutoLoader Business::OnlinePayment);
@EXPORT = qw();
@EXPORT_OK = qw();
$VERSION = '0.01';

$DEBUG = 0;

sub set_defaults {
    my $self = shift;
    $self->server('secure.e2.com.au');
    $self->port('443');
    $self->path('/payment-api/cpan-001/');
}

sub revmap_fields {
    my($self,%map) = @_;
    my %content = $self->content();
    foreach(keys %map) {
        $content{$_} = ref($map{$_})
                         ? ${ $map{$_} }
                         : $content{$map{$_}};
    }
    $self->content(%content);
}

sub get_fields {
    my($self,@fields) = @_;

    my %content = $self->content();
    my %new = ();
    foreach( grep defined $content{$_}, @fields) { $new{$_} = $content{$_}; }
    return %new;
}

sub submit {
    my($self) = @_;
    my %content = $self->content;

    $content{'exp_date'} =~ /^(\d+)\D+(\d+)$/
      or croak "unparsable expiration $content{exp_date}";
    my ($month, $year) = ( $1, $2 );
    $month += 0;
    $year += 2000 if $year < 2000; #not y4k safe, oh shit

    $self->revmap_fields(
      E2P_CLIENTID      => 'login',
      E2P_CLIENTPASS    => 'password',
      E2P_DESCRIPTION   => 'description',
      E2P_CARDNUMBER    => 'card_number',
      E2P_EXP_M         => \$month,
      E2P_EXP_Y		=> \$year,
      E2P_NAMEONCARD  	=> 'name',
      E2P_AMOUNT      	=> 'amount',
      E2P_CCV         	=> \'',
      E2P_TESTMODE      => \( $self->test_transaction() ? 'true' : 'false' ),
    );
    %content = $self->content;
    if ( $DEBUG ) {
      warn "content:$_ => $content{$_}\n" foreach keys %content;
    }

    $self->required_fields(qw/amount card_number exp_date description/);

    my %post_data = $self->get_fields( map "E2P_$_", qw(
      CLIENTID CLIENTPASS DESCRIPTION CARDNUMBER EXP_M EXP_Y NAMEONCARD AMOUNT CCV TESTMODE
    ) );
    if ( $DEBUG ) {
      warn "post_data:$_ => $post_data{$_}\n" foreach keys %post_data;
    }

    my $pd = make_form(%post_data);

    my $server = $self->server();
    my $port = $self->port();
    my $path = $self->path();

    my($page,$server_response,%headers) =
      get_https($server,$port,$path . '?' . $pd ,'');

    
    my %results = map { split  /=/ }  split("\n", $page);


    if ( $results{"AUTHORISED"} == "TRUE" ) {
      $self->is_success(1);
      $self->result_code($results{"RESULT"});
      $self->authorization($results{"TEXT"});
    } else {
      $self->is_success(0);
      $self->result_code($results{"RESULT"});
      $self->error_message($results{"TEXT"});
    }

}

1;
__END__

=head1 NAME

Business::OnlinePayment::E2Payments - E2Payments backend for Business::OnlinePayment

=head1 SYNOPSIS

  use Business::OnlinePayment;

  my $tx = new Business::OnlinePayment("E2Payments");
  $tx->content(
      login          => 'test',  	#E2P_CLIENT
      password       => 'testpass',     #E2P_PASSWORD
      description    => '138456: Fried Wombat & Tomato Sauce',
      amount         => '49.95',
      name           => 'Bertie Beatle',
      card_number    => '1234123412341234',
      exp_date       => '09/02'      
  );
  $tx->submit();

  if($tx->is_success()) {
      print "Card processed successfully: ".$tx->authorization."\n";
  } else {
      print "Card was rejected: ".$tx->error_message."\n";
  }

=head1 DESCRIPTION

For detailed information see L<Business::OnlinePayment>.

=head1 NOTE

=head1 COMPATIBILITY

This module implements E2Payments API Version 1 (Simple Transaction
Mode).  See http://www.e2.com.au/ for further subscription details

=head1 AUTHOR

Aidan Mountford <aidan@oz.to>

=head1 SEE ALSO

perl(1). L<Business::OnlinePayment>.

=cut

