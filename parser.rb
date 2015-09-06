require 'nokogiri'
require 'chronic'


dirs = Dir.glob("*")
non_posts = ["_site"]

dirs -= non_posts

dirs.each do |dir|
  puts dir 
  begin
    doc       = Nokogiri::HTML(File.read(File.join(dir, "index.html")), nil, "UTF-8")
    doc2  = Nokogiri::HTML('<p><a href="http://www.flickr.com/photos/lauvmg/2394204677/" title="friends-love by lauvmg, on Flickr"><img src="http://farm3.static.flickr.com/2175/2394204677_6a611eec2a.jpg" alt="friends-love" height="381" width="500" /></a></p>')
    post_date = Chronic.parse(doc.at_css(".top_o_the_post small").content.gsub(" . by lauvmg", ""))
    post_date.to_s =~ /(\d{4}-\d{2}-\d{2}).*/
    post_date = $1

    title     = doc.at_css(".top_o_the_post h2 a").content

    comments  = doc.at_css(".commentlist").to_s
    tags      = doc.css(".entry p")[-3].css("a").map(&:content)
    list      = doc.css(".entry p")[0..-4].map{|m| m.inner_html.strip.gsub("\u00A0", '')}.compact.reject{|p| p == "" }
    excerpt   = doc.css(".entry p")[0].content
    ps        = list.join("</p>\n<p>")
    contents  = "<p>" << ps << "</p>"
    rendered  = <<TEMPLATE
---
layout: post 
title: #{title}
date: #{post_date}
post_date: #{post_date}
tags: #{tags.join(",")}
excerpt: "#{excerpt}"
comments: #{comments != "" ? true : false}
author:
  name: Laura Vanessa Morales
  bio: "Soy curiosa, me gusta la tecnología, me gusta aprender, uso linux, estoy tratando de aprender python, me interesa saber cómo pasan las cosas en internet, me gusta salir, pasear, conversar, bailar, observar el comportamiento de la gente, escuchar, me gustan los beatles, depeche mode, placebo, the cure, me gusta salir en bicicleta, mecerme en mi hamaca, estar frente al mar, ah, y soy periodista."
---
#{contents}
TEMPLATE
    File.open(File.join("_posts", "#{post_date}-#{dir}.html"), "w") do |f|
      f.write rendered 
    end
    File.open(File.join("_includes", "_posts", "#{post_date}-#{dir}.html_comments.html"), "w") do |f| 
      f.write comments
    end
  rescue Exception => ex
    puts dir
    puts ex.message
  end
end