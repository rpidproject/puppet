# Let's treat ourselves to a nice Vim environment
class profile::vim {
  ensure_packages(
    [
      'vim',
      'vim-puppet',
      'vim-addon-manager',
      'ack-grep'
    ]
  )

  exec { '/usr/bin/vim-addons -w install puppet':
    environment => 'HOME=/',
    unless      => '/usr/bin/vim-addons -w show puppet |grep installed',
    require     => Package['vim-addon-manager'],
  }

  file { '/etc/vim/vimrc':
    source => 'puppet:///modules/profile/vim/vimrc',
  }

  file { '/etc/vim/vimrc.local':
    source => 'puppet:///modules/profile/vim/vimrc.local',
  }

  file { '/usr/share/vim/vimfiles/bundle':
    ensure => directory,
  }

  vcsrepo { '/usr/share/vim/vimfiles/bundle/ctrlp.vim':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ctrlpvim/ctrlp.vim.git',
  }

  vcsrepo { '/usr/share/vim/vimfiles/bundle/ack.vim':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/mileszs/ack.vim.git',
  }

  vcsrepo { '/usr/share/vim/vimfiles/bundle/nerdtree':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/scrooloose/nerdtree.git',
  }
}
