define monitor::process (
  $process,
  $service,
  $pidfile,
  $tool,
  $enable   = true,
  $argument = '',
  $user     = '',
  $template = '',
  $enable   = true
  ) {

  $bool_enable=any2bool($enable)

  $real_template = $template ? {
    ''      => undef,
    default => $template,
  }

  $ensure = $bool_enable ? {
    false => 'absent',
    true  => 'present',
  }

  if ($tool =~ /munin/) {
  }

  if ($tool =~ /collectd/) {
  }

  if ($tool =~ /monit/) {
    monit::checkpid { $name:
      pidfile      => $pidfile,
      process      => "${process}${argument}",
      startprogram => "/etc/init.d/${service} start",
      stopprogram  => "/etc/init.d/${service} stop",
      enable       => $bool_enable,
    }
  }

  if ($tool =~ /nagios/) {
    nagios::service { $name:
      ensure        => $ensure,
      template      => $real_template,
      check_command => $process ? {
        undef   => "check_nrpe!check_process!${name}" ,
        default => $argument ? {
          undef   => "check_nrpe!check_process!${process}" ,
          ''      => "check_nrpe!check_process!${process}" ,
          default => "check_nrpe!check_processwitharg!${process}!${argument}" ,
        }
      }
    }
  }

  if ($tool =~ /icinga/) {
    icinga::service { $name:
      ensure        => $ensure,
      template      => $real_template,
      check_command => $process ? {
        undef   => "check_nrpe!check_process!${name}" ,
        default => $argument ? {
          undef   => "check_nrpe!check_process!${process}" ,
          ''      => "check_nrpe!check_process!${process}" ,
          default => "check_nrpe!check_processwitharg!${process}!${argument}" ,
        }
      }
    }
  }

  if ($tool =~ /puppi/) {
    puppi::check { $name:
      enable   => $bool_enable,
      hostwide => 'yes',
      command  => $process ? {
        undef   => "check_procs -c 1: -C ${name}" ,
        default => $argument ? {
          undef   => "check_procs -c 1: -C ${process}" ,
          ''      => "check_procs -c 1: -C ${process}" ,
          default => "check_procs -c 1: -C ${process} -a ${argument}" ,
        }
      }
    }
  }

}
