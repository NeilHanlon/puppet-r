define r::package($r_path = '', $repo = 'http://cran.rstudio.com', $dependencies = false, $timeout = 300, $local = false, $creates = undef, $shortname = undef) {

  if $local == true
  {
    $repostring = "NULL"
  }
  else
  {
    $repostring = "'${repo}'"
  }

  if $r_path == '' {
    $binary = '/usr/bin/R'
  }
  else
  {
    $binary = $r_path
  }

  if $shortname == undef {
    $shortnamestring = $name
  }
  else {
    $shortnamestring = $shortname
  }

  $command = $dependencies ? {
    true    => "${binary} -e \"install.packages('${name}', repos=${repostring}, dependencies = TRUE)\"",
    default => "${binary} -e \"install.packages('${name}', repos=${repostring}, dependencies = FALSE)\""
  }

  exec { "install_r_package_${name}":
    command => $command,
    timeout => $timeout,
    unless => "${binary} -q -e \"find.package('${shortnamestring}')\" | grep 'Error'",
    creates => $creates,
    require => Class['r']
  }

}
