require 'formula'

class JdkInstalled < Requirement
  fatal true
  satisfy{ which 'javac'}
  def message; <<-EOS.undent
    A JDK is required.  You can get the official Oracle installers from:
    http://www.oracle.com/technetwork/java/javase/downloads/index.html
    EOS
  end
end

class JavaHome < Requirement
  fatal true
  satisfy { ENV["JAVA_HOME"] }
  def message; <<-EOS.undent
    JAVA_HOME is not set:  please set it to the correct value for your Java
    installation. For instance:
    /Library/Java/JavaVirtualMachines/jdk1.7.0_11.jdk/Contents/Home
    EOS
  end
end

class Pydoop < Formula
  homepage 'http://http://pydoop.sourceforge.net/'
  url 'http://sourceforge.net/projects/pydoop/files/Pydoop-0.9/pydoop-0.9.1.tar.gz'
  sha1 'bd26426c49a293196d6ef20c751d2d18c0c7feea'

  depends_on JdkInstalled.new
  depends_on JavaHome.new
  depends_on 'boost'
  depends_on 'hadoop' unless(ENV["HADOOP_HOME"])

  def install
    unless(ENV["HADOOP_HOME"])
      ohai "HADOOP_HOME is not set. Using brewed version"
      ENV.append 'HADOOP_HOME', Formula.factory('hadoop').libexec
    end
    unless(ENV["BOOST_PYTHON"])
      ENV['BOOST_PYTHON'] = 'boost_python-mt'
    end
    system 'python', 'setup.py', 'build'

    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages
    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--install-scripts=#{bin}",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
      "--record=installed-files.txt"
    ]
    system "python", "-s", "setup.py", *args

    prefix.install %w[test examples]
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  def caveats; <<-EOS.undent
    If you use the Homebrew version of Python, you might get a
    "PyThreadState_Get: no current thread" error. In this case, try
    reinstalling boost with the --build-from-source option. For
    details, see:
    https://github.com/mxcl/homebrew/wiki/Common-Issues
    EOS
  end

end
