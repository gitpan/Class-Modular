# This file is part of Class::Modular and is released under the terms
# of the GPL version 2, or any later version at your option. See the
# file README and COPYING for more information.
# Copyright 2004 by Don Armstrong <don@donarmstrong.com>.
# $Id: $


use Test::Simple tests => 9;

use UNIVERSAL;

my $destroy_hit = 0;

{
     # Foo require.
     $INC{'Foo.pm'} = '1';
     package Foo;

     use base qw(Class::Modular);
     use constant METHODS => 'blah';

     sub blah {
	  return 1;
     }

     sub _methods {
          return qw(blah);
     }

     sub _destroy{
	  $destroy_hit = 1;
     }
}

{
     # Bar require.
     $INC{'Bar.pm'} = '1';
     package Bar;

     use base qw(Class::Modular);
     use constant METHODS => 'bleh';

     sub bleh {
	  return 1;
     }

     sub _methods {
          return qw(bleh);
     }
}




my $foo = new Foo(qw(bar baz));

# 1: test new
ok(defined $foo and UNIVERSAL::isa($foo,'Class::Modular'), 'new() works');

# 2: test load()
ok(exists $foo->{__class_modular}{_subclasses}{Foo}, 'load() works');
# 3: test AUTOLOAD
ok($foo->blah, 'AUTOLOAD works');

# Check override
$foo->override('blah',sub{return 2});
ok($foo->blah == 2, 'override() works');

# Check can
# 5: Check can
ok($foo->can('blah'),'can() works');

# Check clone
ok(defined $foo->clone, 'clone() works');

# Check handledby
ok($foo->handledby('blah') eq 'Foo', 'handledby() works');

# Check DESTROY
undef $foo;
ok($destroy_hit,'DESTROY called _destroy');

# Check non-existant _destroy doesn't cause a failure

eval {my $bar = new Bar();
      undef $bar;
 };
ok($@ eq '','Non existant _destroy not a problem');
