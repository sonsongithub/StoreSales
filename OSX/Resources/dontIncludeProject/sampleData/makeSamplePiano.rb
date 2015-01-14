require 'sqlite3'

def process(table)

	db=SQLite3::Database.new('SamplePiano.sql')
	sql="select * from #{table}"

	columns, *rows = db.execute2(sql)
	
	id_column = columns.index("id")
	units_column = columns.index("units")
	beginDate_column = columns.index("beginDate")
	endDate_column = columns.index("endDate")

	db.transaction do
		sql = "update #{table} set units = ? where id = ?"
		rows.each{|e|
			db.execute(sql, (1 + (2 * rand - 1)) * e[units_column].to_f + 100 * rand, e[id_column])
		}
	end

	sql="select min(beginDate), max(beginDate), min(endDate), max(endDate) from #{table}"
	result=db.execute(sql)
	move_ = 0
	result.each do |m|
		puts m[0],m[1],m[2],m[3]
		move_ = m[3].to_i - m[0].to_i
	end

	move_ = move_ + 24 * 3600 * 1

	db.transaction do
		sql = "insert into #{table} (dateIdentifier, CMA, ISAN, ISRC, UPC, appleIdentifier, artistShow, assetContentFlavor, beginDate, countryCode, 	customerCurrency, customerPrice, endDate, labelStudioNetwork, preorder, productTypeIdentifier, provider, providerCountry, royaltyPrice, royaltyCurrency, seasonPass, titleEpisodeSeason, units, vendorIdentifier) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
		rows.each{|e|
			e[beginDate_column] = e[beginDate_column].to_i - move_
			e[endDate_column] = e[endDate_column].to_i - move_
			db.execute(sql, e[0],e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8],e[9],e[10],e[11],e[12],e[14],e[15],e[16],e[17],e[18],e[19],e[20],e[21],e[22],e[23],e[24])
		}
	end

	sql="select * from #{table}"
	result=db.execute(sql)
	result.each{|e|
		puts e.length
	}
	puts result.length
	db.close
end

def main
	process("daily")
	process("weekly")
end

main()