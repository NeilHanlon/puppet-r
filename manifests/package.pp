define r::package($r_path = '', $repo = 'http://cran.rstudio.com', $dependencies = false, $timeout = 300, $local = FALSE) {

  if $local == TRUE
  {
    $repostring = NULL
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

  $command = $dependencies ? {
    true    => "${binary} -e \"install.packages('${name}', repos=${repostring}, type='source' dependencies = TRUE)\"",
    default => "${binary} -e \"install.packages('${name}', repos=${repostring}, type='source' dependencies = FALSE)\""
  }

  exec { "install_r_package_${name}":
    command => $command,
    timeout => $timeout,
    unless  => "${binary} -q -e \"'${name}' %in% installed.packages()\" | grep 'TRUE'",
    require => Class['r']
  }

}
