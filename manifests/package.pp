define r::package($r_path = '', $repo = 'http://cran.rstudio.com', $dependencies = false,
                  $timeout = 300, $local = false, $creates = undef, $shortname = undef,
                  $environment = [], $configure_arguments = '') {

  /**
   * Set local to TRUE if you are installing a local tar.gz packages.
   * this makes sure repo gets passed NULL.
   */
  if $local == true {
    $repostring = "NULL"
  }
  else {
    $repostring = "'${repo}'"
  }

  /**
   * On linux all packages are compiled.
   * You can pass arguments to the compiler using $configure_arguments
   */
  if $configure_arguments == '' {
    $configurestring = ''
  }
  else {
    $configurestring = "configure.args='${configure_arguments}', "
  }

  /**
   * Its possible to override the location of the R binary if you are using multiple versions of R.
   */
  if $r_path == '' {
    $binary = '/usr/bin/R'
  }
  else
  {
    $binary = $r_path
  }

  /**
   * Short name is required when installing a local file. Otherwise we can't check the package was installed
   * to /usr/lib64/R/library properly.
   */
  if $shortname == undef {
    $shortnamestring = $name
  }
  else {
    $shortnamestring = $shortname
  }

  $command = $dependencies ? {
    true => "echo \"install.packages('${name}', repos=${repostring}, ${configurestring}dependencies = TRUE)\" | R CMD BATCH /dev/stdin /dev/stdout | (grep 'non-zero exit status' || exit 0 && exit 1)",
    default => "echo \"install.packages('${name}', repos=${repostring}, ${configurestring}dependencies = FALSE)\" | R CMD BATCH /dev/stdin /dev/stdout | (grep 'non-zero exit status' || exit 0 && exit 1)"
  }

  exec { "install_r_package_${name}":
    environment => $environment,
    command => $command,
    timeout => $timeout,
    path => ["/bin", "/usr/bin", "/usr/sbin", "/sbin"],
    unless => "echo \"'${shortnamestring}' %in% rownames(installed.packages())\" | Rscript --quiet /dev/stdin | grep -v FALSE",
    creates => $creates,
    require => Class['r']
  }

}
