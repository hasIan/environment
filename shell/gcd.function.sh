# Change into gopath directory
# See usage block for details
#
# If you use bash, you might like this better if you set the
# cdspell shell option (shopt -s cdspell), which will keep
# you from having to remember the exact casing of user and
# repo names inside your GOPATH.
gcd() {
  local gopath=$(echo $GOPATH | cut -f1 -d":")
  if [ -z "$gopath" ]; then
    echo "$0: no GOPATH set"
    return
  elif [ ! -d "$gopath" ]; then
    echo "$0: no such directory $gopath"
    return
  fi

  local target
  local cd=cd
  local topdir=src
  local github_user=${GITHUB_USER:-has$USER}
  while [ -z "$target" -a "$*" ]; do
    case $1 in
        -p|--pk*)
          topdir=pkg/`go env GOOS GOARCH | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/_/g'`;;
        -u|--pu*)
          cd=pushd;;
        *)
          target=$1;;
    esac
    shift
  done

  if [ -z "$target" ]; then
    cat <<-GCD_USAGE
	usage: `basename $0` [-p|--pkg] [-u|--push] <target>|"/"
	  -p chdir into pkg hierarchy instead of src
	  -u use pushd instead of cd

	Attempts to intelligently chdir inside of your GOPATH. If you have
	a compound GOPATH, it plucks the first entry off of the GOPATH and
	works with that.

	"github.com" and "code.google.com/p" will automatically be prefixed
	when looking for a target directory. Additionally will first look
	for <target> under your github user name (currently "$github_user",
	configurable with the GITHUB_USER environment variable) so that you
	don't have to specify a user directory if you're changing into your
	own project directories.

	Passing "/" as the target changes to your root GOPATH.
GCD_USAGE
    return
  fi

  if [ "$target" == "/" ]; then
    $cd $gopath
     return
  fi

  local searchpath="github.com code.google.com/p"
  local d
  local candidate

  for d in `echo $searchpath`; do
    candidates="$gopath/$topdir/$d/$github_user/$target $gopath/$topdir/$d/$target $gopath/$topdir/$d/$USER/$target"
    for candidate in `echo $candidates`; do
      if [ -d "$candidate" ]; then
				echo "Trying $candidate"
				$cd "$candidate"
        return
      fi
    done
  done

  $cd "$gopath/$topdir/$target"
}
