package Bric::Util::Grp::User;

=head1 NAME

Bric::Util::Grp::User - Interface to Bric::Biz::Person::User Groups

=head1 VERSION

$Revision: 1.6 $

=cut

# Grab the Version Number.
our $VERSION = (qw$Revision: 1.6 $ )[-1];

=head1 DATE

$Date: 2002-01-06 04:40:37 $

=head1 SYNOPSIS

See Bric::Util::Grp

=head1 DESCRIPTION

See Bric::Util::Grp.

=cut

################################################################################
# Dependencies
################################################################################
# Standard Dependencies
use strict;

################################################################################
# Programmatic Dependences
use Bric::Util::Coll::Priv;

################################################################################
# Inheritance
################################################################################
use base qw(Bric::Util::Grp);

################################################################################
# Function and Closure Prototypes
################################################################################
my ($get_priv_coll);

################################################################################
# Constants
################################################################################
use constant DEBUG => 0;

################################################################################
# Fields
################################################################################
# Public Class Fields

################################################################################
# Private Class Fields
my ($class, $mem_class);

################################################################################

################################################################################
# Instance Fields
BEGIN {
    Bric::register_fields({
			 # Public Fields

			 # Private Fields
			 _privs => Bric::FIELD_NONE
			});
}

################################################################################
# Class Methods
################################################################################

=head1 INTERFACE

=head2 Constructors

Inherited from Bric::Util::Grp.

=head2 Destructors

=over 4

=item $attr->DESTROY

Dummy method to prevent wasting time trying to AUTOLOAD DESTROY.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=back

=cut

sub DESTROY {}

################################################################################

=head2 Public Class Methods

=over

=item $supported_classes = Bric::Util::Grp->get_supported_classes()

This will return an anonymous hash of the supported classes in the group as keys
with the short name as a value. The short name is used to construct the member
table names and the foreign key in the table.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub get_supported_classes { { 'Bric::Biz::Person::User' => 'user' } }

################################################################################

=item $class_id = Bric::Util::Grp::User->get_class_id()

This will return the class ID that this group is associated with.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub get_class_id { 8 }

################################################################################

=item my $secret = Bric::Util::Grp::User->get_secret()

Returns false, because this is not a secret type of group, but one that can be
used by users.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub get_secret { 0 }

################################################################################

=item my $class = Bric::Util::Grp::User->my_class()

Returns a Bric::Util::Class object describing this class.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> Uses Bric::Util::Class->lookup() internally.

=cut

sub my_class {
    $class ||= Bric::Util::Class->lookup({ id => 8 });
    return $class;
}

################################################################################

=item my $class = Bric::Util::Grp::User->member_class()

Returns a Bric::Util::Class object describing the members of this group.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> Uses Bric::Util::Class->lookup() internally.

=cut

sub member_class {
    $mem_class ||= Bric::Util::Class->lookup({ id => 2 });
    return $mem_class;
}

################################################################################

=back

=head2 Public Instance Methods

Most are inherited from Bric::Util::Grp. However, there are special methods here
for managing privileges.

=over 4

=item my (@privs || $privs_aref) = $grp->get_privs

=item my (@privs || $privs_aref) = $grp->get_privs(@priv_ids)

Returns a list or anonymous array of Bric::Util::Priv objects set for this group.
To manipulate those objects, see Bric::Util::Priv for its interface. Call
$grp->save() to save your changes.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub get_privs {
    my $privs = &$get_priv_coll($_[0]);
    $privs->get_objs(@_);
}

################################################################################

=item $self = $grp->new_priv($grp, $value)

Creates and returns a new Bric::Util::Priv object for this group. Pass in the
Bric::Util::Grp object to which to grant the privilege, and the privilege value.
Call $grp->save() to save your changes.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub new_priv {
    my ($self, $grp, $value) = @_;
    my $privs = &$get_priv_coll($self);
    $privs->new_obj({ usr_grp => $self, obj_grp => $grp, value => $value });
}

################################################################################

=item $self = $grp->del_privs(@priv_ids);

Deletes the privileges associated with this group by their IDs. If no
Bric::Util::Priv object IDs are passed, then all the privs associated with thos
group will be deleted. Call $grp->save() to save your changes.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub del_privs {
    my $privs = &$get_priv_coll($_[0]);
    $privs->del_objs(@_);
}

################################################################################

=item $self = $grp->save

Saves all changes to the group, including any changes to permissions.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub save {
    my $self = shift;
    my $id = $self->get_id;
    $self->SUPER::save(@_);

    my $privs = &$get_priv_coll($self);
    $privs->save($id ? undef : $self->get_id) if $privs;
}

################################################################################

=back

=head1 PRIVATE

=head2 Private Constructors

NONE.

=head2 Private Class Methods

NONE.

=head2 Private Instance Methods

NONE.

=head2 Private Functions

=over 4

=item my Bric::Util::Coll::Priv $priv_coll = &$get_priv_coll($self)

Returns a collection of Bric::Util::Priv objects set for this group.

B<Throws:> NONE.

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

$get_priv_coll = sub {
    my Bric::Util::Grp::User $self = shift;
    my ($id, $privs) = $self->_get('id', '_privs');
    return $privs if $privs || ! defined $id;
    $privs = Bric::Util::Coll::Priv->new({usr_grp_id => $id});
    $self->_set(['_privs'], [$privs]);
    $self->_set__dirty; # Unset the dirty flag.
    return $privs;
};

1;
__END__

=back

=head1 NOTES

NONE.

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Bric|Bric>, 
L<Bric::Biz::Person::User|Bric::Biz::Person::User>, 
L<Bric::Util::Priv|Bric::Util::Priv>

=cut

