#!/usr/bin/env ruby

class Xapian < Formula
  desc "C++ search engine library"
  homepage "https://xapian.org/"
  url "https://oligarchy.co.uk/xapian/1.4.18/xapian-core-1.4.18.tar.xz"
  sha256 "196ddbb4ad10450100f0991a599e4ed944cbad92e4a6fe813be6dce160244b77"
  license "GPL-2.0-or-later"
  version_scheme 1

  livecheck do
    url :homepage
    regex(/latest stable version.*?is v?(\d+(?:\.\d+)+)</im)
  end

  depends_on "sphinx-doc" => :build
  depends_on "python@3.9"

  uses_from_macos "zlib"

  on_linux do
    depends_on "util-linux"
  end

  skip_clean :la

  resource "bindings" do
    url "https://oligarchy.co.uk/xapian/1.4.18/xapian-bindings-1.4.18.tar.xz"
    sha256 "fe52064e90d202f7819130ae3ad013c8b2b9cb517ad9fd607cf41d0110c5f18f"
  end

  patch do
    url "https://raw.githubusercontent.com/yqrashawn/homebrew-tmp-xapian/master/patches/xapian-1.4-no-close-retry-on-eintr.patch"
    sha256 "ba70d6bb0803e45ae7ac6ce8183074be2340aad1d3eab043c5fbe8a610cbca93"
  end

  def install
    python = Formula["python@3.9"].opt_bin/"python3"
    ENV["PYTHON"] = python

    ENV.prepend 'CXXFLAGS', '-g -O0 -gcolumn-info'
    system "./configure",
           "CXXFLAGS=-g -O0 -gcolumn-info",
           "--disable-dependency-tracking",
           "--disable-silent-rules",
           "--prefix=#{prefix}"
    system "make", "install"

    # resource("bindings").stage do
    #   ENV["XAPIAN_CONFIG"] = bin/"xapian-config"

    #   xy = Language::Python.major_minor_version python
    #   ENV.prepend_create_path "PYTHON3_LIB", lib/"python#{xy}/site-packages"

    #   ENV.append_path "PYTHONPATH", Formula["sphinx-doc"].opt_libexec/"lib/python#{xy}/site-packages"
    #   ENV.append_path "PYTHONPATH", Formula["sphinx-doc"].opt_libexec/"vendor/lib/python#{xy}/site-packages"

    #   # Fix build on Big Sur (darwin20)
    #   # https://github.com/xapian/xapian/pull/319
    #   inreplace "configure", "*-darwin[91]*", "*-darwin[912]*"

    #   system "./configure",
    #          "CXXFLAGS=-g -O0 -gcolumn-info",
    #          "--disable-dependency-tracking",
    #          "--prefix=#{prefix}",
    #          "--with-python3"

    #   system "make", "install"
    # end
  end

  test do
    system bin/"xapian-config", "--libs"
    system Formula["python@3.9"].opt_bin/"python3", "-c", "import xapian"
  end
end
