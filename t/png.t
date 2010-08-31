use strict;

use File::Path ();
use File::Spec::Functions;
use FindBin ();
use Test::More tests => 36;
#require Test::NoWarnings;

use Image::Scale;

my $tmpdir = catdir( $FindBin::Bin, 'tmp' );
if ( -d $tmpdir ) {
    File::Path::rmtree($tmpdir);
}
mkdir $tmpdir;

my @types = qw(
    rgb
    rgba
    rgba_interlaced
    rgba16
    gray
    gray_alpha
    gray_interlaced
    palette
    palette_alpha
);

# We don't need to test all resizes, JPEG can do that
my @resizes = qw(
    resize_gd_fixed_point
);

# width/height
for my $type ( @types ) {    
    my $im = Image::Scale->new( _f("${type}.png") );
    
    is( $im->width, 160, "PNG $type width ok" );
    is( $im->height, 120, "PNG $type height ok" );
}

# Normal width resize
for my $resize ( @resizes ) {
    for my $type ( @types ) {
        my $outfile = _tmp("${type}_${resize}_w100.png");
        
        my $im = Image::Scale->new( _f("${type}.png") );
        $im->$resize( { width => 100 } );
        $im->save_png($outfile);
        my $data = $im->as_png();
    
        is( _compare( _load($outfile), "${type}_${resize}_w100.png" ), 1, "PNG $type $resize 100 file ok" );
        is( _compare( \$data, "${type}_${resize}_w100.png" ), 1, "PNG $type $resize 100 scalar ok" );
    }
}

# XXX palette_bkgd

END {
    #File::Path::rmtree($tmpdir);
}

sub _f {    
    return catfile( $FindBin::Bin, 'images', 'png', shift );
}

sub _tmp {
    return catfile( $tmpdir, shift );
}

sub _load {
    my $path = shift;
    
    open my $fh, '<', $path or die "Cannot open $path";
    binmode $fh;
    my $data = do { local $/; <$fh> };
    close $fh;
    
    return \$data;
}    

sub _compare {
    my ( $test, $path ) = @_;
    
    my $ref = _load( catfile( $FindBin::Bin, 'ref', 'png', $path ) );
    
    return $$ref eq $$test;
}

sub _out {
    my $ref = shift;
    
    open my $fh, '>', 'out.png';
    binmode $fh;
    print $fh $$ref;
    close $fh;
}
