require 'rubygems'
require 'bliss'

#path = 'http://www.universobit.com.ar/AvisosUniversobit/trovit/AvisosUniversobit_1.xml'
#path = 'http://www.aestrenar.com.ar/backend/rssAestrenar.xml'
#path = 'http://procarnet.es/feed/sumavisos/sumavisos.xml'
#path = 'http://taakidom.pl/import/trovit/trovit.xml'
#path = 'http://www.deautos.com/sumavisos/feed.xml'
#path = 'http://www.autocosmos.com.ar/webservices/exchange/sumavisos.ar.xml.gz'

#path = 'http://www.workgate.co.jp/feeds/sumavisos/sumavisos.xml'
#path = 'http://www.bydgoszczak.pl/export/trovit_praca'
#path = 'http://www.espacioinmobiliario.mx/feeds/feed.xml' # da timeout

#path = 'http://www.indexempleos.com/peru/jobs.xml'

#path = 'http://www.bydgoszczak.pl/export/trovit_praca'

path = 'http://www.tokkoro.com/cron/adsdeck_feed.xml'

# encoding
#path = 'http://www.topdiffusion.com/flux/topdiffusion_adsdeck.xml'
#path = 'http://www.workgate.co.jp/feeds/sumavisos/sumavisos.xml' # el problema es que viene con job, en lugar de ad
#path = 'http://www.ultramotors.com.br/trovit/'

#path = 'http://localhost:8080/maixon.xml'

#path = 'http://www.kasaki.com.br/somanuncios.xml' # uppercase
#path = 'http://canadajobsandcareers.ca/feed_adsdeck.php'

#path = 'http://www.goemploi.com/france/jobs.xml'
#path = 'http://www.monsieurjob.com/feeds/adsdeck.php'
#path = 'http://www.imovelajato.com.br/feeds/olx/olx.xml'

p = Bliss::ParserMachine.new(path, 'output.xml')
p.wait_tag_close('AD')
#p.max_unhandled_bytes = 20000

count = 0
p.on_root { |root|
  #puts root
}
#p.on_tag_open { |depth|
#  if depth.last =~ /[A-Z]/ then
#    puts 'uppercase detected!'
#    p.close
#  end
#}
p.on_tag_open('AD') { |depth|
  #puts depth.inspect
}
p.on_tag_close('AD') { |hash|
  count += 1

  dict = {"make"=>"name"}
  only_in_dict = false
  hash = hash.inject({}) { |h,v| key = dict.invert[v[0]]; key ||= v[0] unless only_in_dict; h[key] = v[1] if key; h }
  
  #puts hash.inspect
  #puts hash['type']
  #puts hash.keys.inspect
  #if count == 100
  #  p.close
  #end
}

begin
  p.parse
rescue Bliss::EncodingError
  puts "resqued!"
end

puts "Root: #{p.root}"
puts "Count : #{count}"
