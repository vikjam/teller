#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'mail'
require 'parseconfig'
require 'open3'

class Teller < Thor

    desc "submit QSUBCMD", "submit QSUBCMD to qsub and get completed notification"
    def submit(*args)
        # Load information
        pbapi = ENV["PUSHBULLET_API"]

        # Join *args into a single qsubcmd
        qsubcmd = args.join(' ')

        # Compile string and send to command line
        cmd                             = "qsub -b y -cwd #{qsubcmd}"
        stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
        response                        = stdout.gets

        # Output response
        puts response

        # Extract job ID
        jobid  = response[/job\ \d+/].gsub('job ', '')

        # Proceed if successful
        exit_status = wait_thr.value

        if exit_status.success?
            File.open("teller-#{jobid}.py", 'w') { | f |
		f.puts('import os')
                f.puts('from pushbullet import Pushbullet')
                f.puts('pb = Pushbullet(os.environ["PUSHBULLET_API"])')
                f.puts(%Q[push = pb.push_note("Equity Job #{jobid} Completed", "Finished: #{qsubcmd}")])
	    }

            nstdin, nstdout, nstderr, nwait_thr = Open3.popen3("qsub -b y -hold_jid #{jobid} -cwd python teller-#{jobid}.py")
            puts nstdout.gets

        end
    end

    desc "watch JOBID", "received notification of previously submitted JOBID"
    def watch(jobid)
        notifycmd = %Q[ruby ]
        watchcmd  = "qsub -hold_jid #{jobid} -cwd '#{notifycmd}'"
        puts("#{watchcmd}")
    end

end

# End of script
