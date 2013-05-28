require 'formula'

class RetextIcons < Formula
  url 'http://sourceforge.net/projects/retext/files/Icons/ReTextIcons_r3.tar.gz'
  sha1 'c51d4a687c21b7de3fd24a14a7ae16e9b0869e31'
end

class Retext < Formula
  homepage 'http://sourceforge.net/projects/retext/'
  url 'http://sourceforge.net/projects/retext/files/ReText-4.0/ReText-4.0.0.tar.gz'
  # 4.1 will drop python 2.x support!
  sha1 '4a2ada905d790b4d8f3709271945008f50cd4d06'

  depends_on 'pyqt'
  depends_on 'markups' => :python
  depends_on 'docutils' => :python
  depends_on 'enchant'
  depends_on LanguageModuleDependency.new(:python, 'pyenchant', 'enchant')

  def install
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
    ]
    system "python", "-s", "setup.py", *args

    # Copy icons to correct place an fix the path
    icons_dir = lib/which_python/'site-packages/ReText/icons/'
    RetextIcons.new.brew { icons_dir.install Dir['*.*'] }
    inreplace lib/which_python/'site-packages/ReText/__init__.py',
              'icon_path = "icons/"',
              "icon_path = '#{lib/which_python}/site-packages/ReText/icons/'"
  end

  def caveats
    <<-EOS.undent
      ReText needs "pyenchant", which in turn needs enchant.
      So please first `brew install enchant` and then `pip install pyenchant`.

      Run ReText by typing `retext.py`
    EOS
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
