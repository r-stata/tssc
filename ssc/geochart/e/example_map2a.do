set more off
clear

input str30 province int value
      "Sumatera Utara" 21
      "Sumatera Barat" 34
      "Bali" 34
      "Sulawesi Selatan" 23
      "Bengkulu" 65
      "Jawa Tengah" 76
      "Sulawesi Tengah" 46
      "Sulawesi Utara" 78
      "Jakarta Raya" 67
      "Jawa Timur" 45
      "Nusa Tenggara Timur" 88
      "Nusa Tenggara Barat" 67
      "Sulawesi Barat" 56
      "Riau" 76
      "Banten" 53
      "Jawa Barat" 12
      "Yogyakarta JW" 12
      "Sulawesi Tenggara" 33
      "Lampung" 22
      "Papua" 10
      "Kalimantan Timur" 44
      "Gorontalo" 77
      "Jambi" 70
      "Sumatera Selatan" 42
      "Aceh" 23
      "Maluku Utara" 12
      "Bangka Belitung" 12
end

list
local webpage "c:\temp\example2.html"
geochart value province , width(800) height(600) save(`"`webpage'"') replace region("ID") resolution("provinces") savebtn


