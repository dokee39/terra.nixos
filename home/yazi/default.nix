{ pkgs, lib, osConfig, ... }:

{
  programs.yazi = {
    enable = true;

    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };

    shellWrapperName = "y";

    plugins = {
      git = pkgs.yaziPlugins.git;
      piper = pkgs.yaziPlugins.piper;
      mime-ext = pkgs.yaziPlugins.mime-ext;
    };

    initLua = ''
      require("git"):setup()

      require("ranger-like"):setup()
      function Linemode:ranger_like()
        return require("ranger-like"):render(self._file)
      end
    '';

    keymap = let
      shellPkg = osConfig.users.users.${osConfig.terra.userName}.shell or pkgs.bashInteractive;
      shellExe = lib.getExe shellPkg;
    in {
      mgr.prepend_keymap = [
        {
          on = "!";
          run = "shell --block -- ${shellExe}";
          desc = "Open shell in current directory";
        }
      ];
    };

    settings = {
      mgr = {
        ratio = [ 1 3 4 ];
        show_symlink = false;
        linemode = "ranger_like";
      };

      plugin = {
        prepend_fetchers = [
          {
            group = "git";
            url = "*";
            run = "git";
          }
          {
            group = "git";
            url = "*/";
            run = "git";
          }
          {
            group = "mime";
            url = "remote://*";
            run = "mime-ext.remote";
            prio = "high";
          }
        ];

        prepend_previewers = [
          {
            url = "*.csv";
            run = ''piper -- bat -p --color=always "$1"'';
          }
          {
            url = "*.md";
            run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          }
        ];
        append_previewers = [
          {
            url = "*";
            run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
          }
        ];
      };
    };

    theme = {
      mgr = {
        border_symbol = " ";
        symlink_target.fg = "cyan";
      };

      tabs = {
        active = { fg = "black"; bg = "cyan"; bold = true; };
        inactive = { fg = "cyan"; bg = "black"; };
      };

      indicator = {
        preview = { reversed = true; };
      };

      mode = {
        normal_main = { fg = "black"; bg = "cyan"; bold = true; };
        normal_alt = { fg = "cyan"; bg = "black"; };
        select_main = { fg = "black"; bg = "magenta"; bold = true; };
        select_alt = { fg = "magenta"; bg = "black"; };
        unset_main = { fg = "black"; bg = "red"; bold = true; };
        unset_alt = { fg = "red"; bg = "black"; };
      };

      filetype.rules = [
        # build by exact filename
        { url = "**/README*"; fg = "yellow"; bold = true; underline = true; }
        {
          url = "**/{Brewfile,bsconfig.json,BUILD,BUILD.bazel,build.gradle,build.sbt,build.xml,Cargo.toml,CMakeLists.txt,composer.json,configure,Containerfile,Dockerfile,Earthfile,flake.nix,Gemfile,GNUmakefile,Gruntfile.coffee,Gruntfile.js,jsconfig.json,Justfile,justfile,Makefile,makefile,meson.build,mix.exs,package.json,Pipfile,PKGBUILD,Podfile,pom.xml,Procfile,pyproject.toml,Rakefile,RoboFile.php,SConstruct,tsconfig.json,Vagrantfile,webpack.config.cjs,webpack.config.js,WORKSPACE}";
          fg = "yellow"; bold = true; underline = true;
        }
        { url = "**/*.ninja"; fg = "yellow"; bold = true; underline = true; }

        # crypto by exact filename
        {
          url = "**/{id_dsa,id_ecdsa,id_ecdsa_sk,id_ed25519,id_ed25519_sk,id_rsa}";
          fg = "green"; bold = true;
        }

        # crypto by extension
        {
          url = "**/*.{age,asc,cer,crt,csr,gpg,kbx,md5,p12,pem,pfx,pgp,pub,sha1,sha224,sha256,sha384,sha512,sig,signature}";
          fg = "green"; bold = true;
        }

        # lossless music
        { url = "**/*.{aif,aifc,aiff,alac,ape,flac,pcm,wav,wv}";
          fg = "cyan"; bold = true;
        }

        # temp
        {
          url = "**/*.{bak,bk,bkp,crdownload,download,fcbak,fcstd1,fdmdownload,part,swn,swo,swp,tmp}";
          dim = true;
        }
        { url = "**/*~"; dim = true; }
        { url = "**/#*#"; dim = true; }

        # compiled
        {
          url = "**/*.{a,bundle,class,cma,cmi,cmo,cmx,dll,dylib,elc,elf,ko,lib,o,obj,pyc,pyd,pyo,so,zwc}";
          fg = "yellow";
        }

        # source
        {
          url = "**/*.{applescript,as,asa,awk,c,c++,c++m,cabal,cc,ccm,clj,cp,cpp,cppm,cr,cs,css,csx,cu,cxx,cxxm,cypher,d,dart,di,dpr,el,elm,erl,ex,exs,f,f90,fcmacro,fcscript,fnl,for,fs,fsh,fsi,fsx,gd,go,gradle,groovy,gvy,h,h++,hh,hpp,hc,hs,htc,hxx,inc,inl,ino,ipynb,ixx,java,jl,js,jsx,kt,kts,kusto,less,lhs,lisp,ltx,lua,m,malloy,matlab,ml,mli,mn,nb,p,pas,php,pl,pm,pod,pp,prql,ps1,psd1,psm1,purs,py,r,rb,rs,rq,sass,scala,scm,scad,scss,sld,sql,ss,swift,tcl,tex,ts,v,vb,vsh,zig}";
          fg = "yellow"; bold = true;
        }

        # image extensions that often won't be caught cleanly by image/*
        { url = "**/*.{dvi,eps,fodg,odg,ps}"; fg = "magenta"; }

        # document extensions that don't fit the simple MIME bucket well
        {
          url = "**/*.{djvu,eml,gdoc,key,keynote,numbers,odp,ods,odt,pages,ppt,pptx,xls,xlsm,xlsx}";
          fg = "green";
        }

        # compressed extensions that don't fit the simple MIME bucket well
        {
          url = "**/*.{ar,br,deb,dmg,iso,lz4,lzh,lzo,phar,qcow,qcow2,rpm,taz,tc,tz,vdi,vhd,vhdx,vmdk,z}";
          fg = "red";
        }

        # MIME-first buckets
        { mime = "image/*"; fg = "magenta"; }
        { mime = "video/*"; fg = "magenta"; bold = true; }
        { mime = "audio/*"; fg = "cyan"; }
        { mime = "message/rfc822"; fg = "green"; }
        {
          mime = "application/{pdf,rtf,msword,vnd.ms-*,vnd.openxmlformats-officedocument.*,vnd.oasis.opendocument.*}";
          fg = "green";
        }
        {
          mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = "red";
        }

        # vfs
        { mime = "vfs/{absent,stale}"; fg = "darkgray"; }

        # filekinds
        { url = "*"; is = "orphan"; fg = "red"; dim = true; }
        { url = "*/"; is = "orphan"; fg = "red"; dim = true; }
        { url = "*"; is = "link"; fg = "cyan"; }
        { url = "*/"; is = "link"; fg = "cyan"; }
        { url = "*"; is = "sock"; fg = "red"; bold = true; }
        { url = "*"; is = "block"; fg = "yellow"; bold = true; }
        { url = "*"; is = "char"; fg = "yellow"; bold = true; }
        { url = "*"; is = "fifo"; fg = "yellow"; }
        { url = "*"; is = "exec"; fg = "green"; bold = true; }

        # dummy
        { url = "*"; is = "dummy"; fg = "red"; dim = true; }
        { url = "*/"; is = "dummy"; fg = "red"; dim = true; }

        # fallback directory
        { url = "*/"; fg = "blue"; bold = true; }
      ];
    };
  };

  xdg.configFile."yazi/plugins/ranger-like.yazi".source = ./plugins/ranger-like.yazi;
}
