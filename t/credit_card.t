BEGIN { $| = 1; print "1..1\n"; }

use Business::OnlinePayment;

my $tx = new Business::OnlinePayment("E2Payments");
$tx->content(
   login          => 'test',         #E2P_CLIENT
   password       => 'testpass',     #E2P_PASSWORD
   description    => '138456: Fried Wombat & Tomato Sauce',
   amount         => '69.96',
   name           => 'Captain Kangaroo',
   card_number    => '1234123412341234',
   exp_date       => '09/02',
);
						

$tx->test_transaction(1); # test, dont really charge
$tx->submit();

if($tx->is_success()) {
    print "ok 1\n";
} else {
    warn "*******". $tx->error_message. "*******";
    print "not ok 1\n";
}
