require 'csv'

zip_array = [] #empty array to store each zipcode entry

#creates array of hashes for each zipcode in question: includes state, rate area, and empty slcsp array
CSV.foreach("slcsp.csv", :headers=>true) do |query| #creates hash for each zipcode that we want to find slcsp for
  entry = Hash["zipcode" => query[0], "state"=>nil, "rate_area" => " ", "slcsp"=>Array.new]
  CSV.foreach("zips.csv", :headers=>true) do |zip|
    if query[0]==zip[0]
      if entry['rate_area']==" " #populates zipcode rate area if it hasn't been filled
        entry['state'] = zip[1]
        entry['rate_area'] = zip[4]
      elsif entry['rate_area']!=zip[4] #changes rate area to blank string if different rate areas found for same zip
        entry['rate_area']=""
      end
    end
  end
  zip_array<<entry
end

#populates the slcsp array for each zipcode entry with all of the silver plans for its corresponding state/rate area
CSV.foreach("plans.csv",:headers=>true) do |plan|
  zip_array.each{|entry|
    if plan[2]=="Silver"&&entry['state']==plan[1]&&entry['rate_area']==plan[4]
        entry['slcsp']<<plan[3].to_f
    end
  }
end

#finds the second cheapest rate in the silver plan array for each zipcode
zip_array.each{|entry|
  if entry['slcsp'].length>1
    entry['slcsp'].sort!
    slcsp = entry['slcsp'][1]
    entry['slcsp']=Array.new
    entry['slcsp']<<slcsp
  end
}

#writes the final results to the csv file
CSV.open("slcsp.csv",'w') do |csv|
  header = ["zipcode","rate"]
  csv << header
  zip_array.each do |zip|
    csv << [zip['zipcode'], zip['slcsp'][0]]
  end
end
