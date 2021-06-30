my $BELONG_THRESHOLD = 2;

sub check-if-mandelbrot(Complex $c, $maxiter){
	check-if-julia($c, $maxiter, &iter-mandelbrot, $BELONG_THRESHOLD)
}

sub check-if-mandelbox(Complex $c, $maxiter){
	check-if-julia($c, $maxiter, &iter-mandelbox, $BELONG_THRESHOLD)
}


sub iter-mandelbrot(Complex $z, Complex $c) {$z**2 + $c;}

sub iter-mandelbox(Complex $z is copy, Complex $c){
	sub box-fold($v){
		my $x = $v.re;
		my $y = $v.im;
		sub rev($n){
			return 2 - $n if $n > 1;
			return -2 - $n if $n < -1;
			return $n;
		}
		rev($x) + rev($y) * 1i;
	}
	sub ball-fold($r, $v){
		my $m = $v.abs;
		my $vnorm = $v / $m;
		return $vnorm * ($m / $r**2) if $m < $r;
		return $vnorm * (1 / $m) if $m < 1;
		return $v;
	}
	sub iter($s, $r, $f, $v, $c){$s*ball-fold($r, $f*box-fold($v)) + $c}
	$z = $c if  $z == 0;
	iter(-1.1, 0.5, 1, $z, $c);
}

sub check-if-julia(Complex $c is copy, $maxiter, &iter, $THRESHOLD){
	my $z = 0+0i;
	for 0..$maxiter {
		return $_ unless -$THRESHOLD < $z.abs < $THRESHOLD;
		$z = &iter($z, $c);
	}
	return True;
}

sub check-julia-range($up, $down, $left, $right, $_scalex, $_scaley, $maxiter, &check){ #scalex/y is the number of subdicisions in each dimension
	my $scalex = $_scalex - 1;
	my $scaley = $_scaley - 1;
	my $deltax = $right - $left;
	my $deltay = $up - $down;
	my $subdiv-sizex = $deltax / $scalex;
	my $subdiv-sizey = $deltay / $scaley;
	my @image = [];

	for 0..$scalex -> $xnum {
		my @current-row = [];
		my $x = $xnum * $subdiv-sizex + $left;
		for 0.. $scaley -> $ynum {
			my $y = $ynum * $subdiv-sizey + $down;
			my $number = $y + $x*(1i);
			@current-row.push(check-if-julia($number, $maxiter, &check, $BELONG_THRESHOLD));
		}
		@image.push(@current-row);
	}
	return @image;
}

sub display-fractal(@image, @alphabet, $true-symbol){
	for @image -> @row {
		for @row -> $point {
			if $point === True {
				print $true-symbol;
				next;
			}
			print @alphabet[$point % @alphabet.elems];
		}
		print "\n";
	}
}

sub MAIN(Int $width, Int $height, Str $type = "mandelbrot", $num-iter = 100){
	given $type {
		when "mandelbrot" {
			display-fractal(check-julia-range(1, -2, -1.5, 1.5, $height, $width, $num-iter, &iter-mandelbrot), <A B C>, ".");
		}
		when "mandelbox" {
			display-fractal(check-julia-range(1, -1, -1, 1, $height, $width, $num-iter, &iter-mandelbox), <A B C>, ".");
		}
		default {
			die "invalid fractal type";
		}
	}
}
