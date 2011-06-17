#!/usr/bin/env ruby

require "mongoid"

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("RT_mongoid")
end

class Registro
    include Mongoid::Document
    field :subida, type: Float
    field :bajada, type: Float
    field :fecha_hora, typo: String  
end

def bytestomb bytes
	mb = bytes.to_f / (1024*1024)
	mb
end

def consulta
  puts "Registros en la BD: " + Registro.count.to_s

  cursor = Registro.all
  puts "Total de Subida: " + cursor.sum(:subida).to_s + " MB"
  puts "Total de Bajada: " + cursor.sum(:bajada).to_s + " MB"
  total = cursor.sum(:subida) + cursor.sum(:bajada)
  puts "Total Consumido: " + total.to_s + " MB"
  
end

interface = "ppp0"
archivo = File.open('/proc/net/dev', 'r')
archivo.each_line do |line|
	#puts line
	if line =~ /ppp0/
		#puts line
		data = line.split('%s:' % interface)[1].split()
		$rx_bytes = data[0]
		$tx_bytes = data[8]
		puts "================================"
		puts "En esta sesion: ".upcase
		puts "Enviados  >>>: " + (bytestomb $tx_bytes).to_s + " MB"
		puts "Recibidos <<<: " + (bytestomb $rx_bytes).to_s + " MB"
	end
end

regsubida = (bytestomb $tx_bytes).to_f
regbajada = (bytestomb $rx_bytes).to_f
tiempo = Time.now

puts "================================"
consulta
puts "--------------------------------"
puts "Desea agregar el registro? Inserte solo S/N: "
respuesta = gets.chomp
if respuesta.downcase == "s"
  registro = Registro.create(subida: regsubida, bajada: regbajada,
                            fecha_hora: tiempo.to_s)
  puts "Registros Almacenados con Exito!"

end

puts "--------------------------------"
consulta
