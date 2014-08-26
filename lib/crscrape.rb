require 'json'
require 'nokogiri'
require 'open-uri'

class Crscrape
  def initialize
    @outarr = Array.new
  end

  # Get links to house, senate, extension of remarks, daily digest
  def loop(congress)
    # Get year
    html = Nokogiri::HTML(open("http://thomas.loc.gov/home/Browse.php?&n=Issues&c="+congress))
    
    temparr = Array.new
    # Loop through table
    html.css("table").css("tr").each do |r|
      if !r.css("td").css("a").empty?
        date = r.css("td")[0].text.strip.gsub(/ {2,}/, " ")
        
      # Set indices to deal with formatting changes
        index = Hash.new
        if congress == "113" || congress == "112"
          index[:house] = 2
          index[:senate] = 3
          index[:extensions] = 4
          index[:digest] = 5
        else
          index[:house] = 1
          index[:senate] = 2
          index[:extensions] = 3
          index[:digest] = 4
        end
      
      house = r.css("td")[index[:house]].css("a")
        if house.length == 2
          househash = Hash.new
          househash[:date] = date
          househash[:type] = "House"
          #househash[:url] = "http://thomas.loc.gov"+house[0]['href']
          #househash[:text] = 
          scrape("http://thomas.loc.gov"+house[0]['href'], househash)
          #temparr.push(househash)
        elsif house.length == 1
          begin
            househash = Hash.new
            househash[:date] = date
            househash[:type] = "House"
            #househash[:url] = "http://thomas.loc.gov"+house[0]['href']
            #househash[:text] = 
            scrape("http://thomas.loc.gov"+house[0]['href'], househash)
            #temparr.push(househash)
          rescue
          
          end
        end

        senate = r.css("td")[index[:senate]].css("a")
        if senate.length == 2
          senatehash = Hash.new
          senatehash[:date] = date
          senatehash[:type] = "Senate"
          #senatehash[:url] = "http://thomas.loc.gov"+senate[0]['href']
          #senatehash[:text] = 
          scrape("http://thomas.loc.gov"+senate[0]['href'], senatehash)
          #temparr.push(senatehash)
        elsif senate.length == 1
          senatehash = Hash.new
          senatehash[:date] = date
          senatehash[:type] = "Senate"
          #senatehash[:url] = "http://thomas.loc.gov"+senate[0]['href']
          #senatehash[:text] = 
          scrape("http://thomas.loc.gov"+senate[0]['href'], senatehash)
          #temparr.push(senatehash)
        end
    
        extensions = r.css("td")[index[:extensions]].css("a")
        if extensions.length == 2
          extensionhash = Hash.new
          extensionhash[:date] = date
          extensionhash[:type] = "Extension of Remarks"
          #extensionhash[:url] = "http://thomas.loc.gov"+extensions[0]['href']
          #extensionhash[:text] = 
          scrape("http://thomas.loc.gov"+extensions[0]['href'], extensionhash)
          #temparr.push(extensionhash)
        elsif extensions.length == 1
          extensionhash = Hash.new
          extensionhash[:date] = date
          extensionhash[:type] = "Extension of Remarks"
          #extensionhash[:url] = "http://thomas.loc.gov"+extensions[0]['href']
          #extensionhash[:text] = 
          scrape("http://thomas.loc.gov"+extensions[0]['href'], extensionhash)
          #temparr.push(extensionhash)
        end

        digest = r.css("td")[index[:digest]].css("a")
        if digest.length == 2
          digesthash = Hash.new
          digesthash[:date] = date
          digesthash[:type] = "Daily Digest"
          digesthash[:url] = "http://thomas.loc.gov"+digest[0]['href']
          digesthash[:text] = Nokogiri::HTML(open("http://thomas.loc.gov"+digest[0]['href'])).text
          @outarr.push(digesthash)
          #temparr.push(digesthash)
        elsif digest.length == 1
          digesthash = Hash.new
          digesthash[:date] = date
          digesthash[:type] = "Daily Digest"
          digesthash[:url] = "http://thomas.loc.gov"+digest[0]['href']
          digesthash[:text] = Nokogiri::HTML(open("http://thomas.loc.gov"+digest[0]['href'])).text
          @outarr.push(digesthash)
          #temparr.push(digesthash)
        end
      end
    end

    return JSON.pretty_generate(@outarr)
  end

  # Scrapes all items and collects them in one chunk of text
  def scrape(url, hash)
    text = ""
    html = Nokogiri::HTML(open(url))
    html.css("div#content").css("a").each do |l|
      if l['href'].include? "cgi-bin"
        link = "http://thomas.loc.gov" + l['href']
        if l['href']
          begin
            itemhash = Hash.new
            itemhash[:date] = hash[:date]
            itemhash[:type] = hash[:type]
            itemhash[:url] = url
            itemhash[:text] = Nokogiri::HTML(open(link)).text
            
            @outarr.push(itemhash)
            #text = text + Nokogiri::HTML(open(link)).text
          rescue
          end
        end
      end
    end
    
    #return text
  end
end
