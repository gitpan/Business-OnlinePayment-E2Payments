use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'         => 'Business::OnlinePayment::E2Payments',
    'VERSION_FROM' => 'E2Payments.pm', # finds $VERSION
    'AUTHOR'       => 'Aidan Mountford <aidan@oz.to>',
    #'NORECURS'     => 1, # dont descend into subdirectories
    'PREREQ_PM'    => { 'Net::SSLeay' => 0,
                        #'Text::CSV_XS' => 0,
                        'Business::OnlinePayment' => 0,
                        'Business::CreditCard' => 0.27,
                      },
);
