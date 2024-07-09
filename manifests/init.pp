class r {
      package { 'R-core': ensure => installed }
      package { 'R-core-devel': ensure => installed }
      package { 'R-devel': ensure => installed }
}
