#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__),'command_line.rb')

opts = Choice.choices

cmd=$0
fname=opts[:infile]
options=opts[:options]
compiler=opts[:compiler] || "gfortran"
unless options==nil
  options.map! {|o| " -"+o}
else
  options=""
end

puts (" Execute #{cmd} --comp #{compiler} #{options} --file #{fname}")
pwd=ENV['PWD']
src_dir=File.dirname(fname)
ext=File.extname(fname)
basename=File.basename(fname,ext)
ext.upcase!

if ext==".F90" 
  stubfile=src_dir+"/"+basename+".stub" 
  # check if stubfile is present or give warning
else
  stubfile=fname
end
wrapper=`wrapit77 < #{stubfile}`
File.open("#{basename}_W.c","w") do |myfile|
	myfile.write(wrapper)
end
`#{compiler}  -fPIC -c #{options} #{basename}_W.c -I${NCARG_ROOT}/include`
`#{compiler} -fPIC -c #{options} #{fname}`
`#{compiler} -fPIC -shared #{options}  -o #{basename}.so #{basename}_W.o #{basename}.o -l#{compiler}`

# remove intermediate files
`rm #{basename}_W.c #{basename}_W.o #{basename}.o`
