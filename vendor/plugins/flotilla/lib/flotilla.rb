begin
  require 'json'
rescue LoadError
  p "Flotilla will not work without the 'json' gem"
end

module ActionView
  module Helpers
    module ScriptaculousHelper
      
      # Insert a flot chart into the page.  <tt>placeholder</tt> should be the 
      # name of the div that will hold the chart, <tt>collections</tt> is a hash 
      # of legends (as strings) and datasets with options as hashes, <tt>options</tt>
      # contains graph-wide options.
      # 
      # Example usage:
      #   
      #  chart("graph_div", { 
      #   "January" => { :collection => @january, :x => :day, :y => :sales, :options => { :lines => {:show =>true}} }, 
      #   "February" => { :collection => @february, :x => :day, :y => :sales, :options => { :points => {:show =>true} } },
      #   :grid => { :backgroundColor => "#fffaff" })
      #
      # options:  
      #   :show_tooltip - activates the tooltip via mouse movments
      #   
      # html_options:
      #   :js_includes - includes flot library inline
      #   :js_tags - wraps resulting javascript in javascript tags if true.  Defaults to true.
      #   :placeholder_tag - appends a placeholder div for graph
      #   :placeholder_size - specifys the size of the placeholder div
      def chart(placeholder, series, options = {}, html_options = {})
        options.reverse_merge!({:show_tooltip => true})
        options.merge!({:grid => {:hoverable => true, :clickable => true}}) if options[:show_tooltip]        
        html_options.reverse_merge!({ :js_includes => true, :js_tags => true, :placeholder_tag => true, :placeholder_size => "800x300" })
        width, height = html_options[:placeholder_size].split("x") if html_options[:placeholder_size].respond_to?(:split)
        
        data, x_is_date, y_is_date = series_to_json(series, options[:show_tooltip])
        if x_is_date
          options[:xaxis] ||= {}
          options[:xaxis].merge!({ :mode => 'time' })
        end
        if y_is_date
          options[:yaxis] ||= {}
          options[:yaxis].merge!({ :mode => 'time' })
        end
        
        var_string, data_string, datas= "\n", "", []

        if options[:show_tooltip]
          #define vars as json
          vs = get_vars(series, x_is_date, y_is_date)
           #vs[0].inspect
          vs.each_with_index do |var,i|
            var_string += "\t\tvar #{var[:name]} = #{var[:data].to_json};\n"
          end
          #add vars to script
          
        end


        if html_options[:js_includes]
          chart_js = <<-EOF
          <!--[if IE]><script language="javascript" type="text/javascript" src="/javascripts/excanvas.pack.js"></script><![endif]-->
          <script language="javascript" type="text/javascript" src="/javascripts/jquery.flot.pack.js"></script>
          <script type="text/javascript">
            $(function () {  #{var_string}
              var plot = jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json}); #{tool_tip_script(placeholder)}
            });
          </script>
          EOF
        else
          chart_js = <<-EOF
          $(function () {  #{var_string}
            var plot = jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json});  #{tool_tip_script(placeholder)}
          });
          EOF
        end        
        
        html_options[:js_tags] ? javascript_tag(chart_js) : chart_js
        output = html_options[:placeholder_tag] ? chart_js + content_tag(:div, nil, :id => placeholder, :style => "width:#{width}px;height:#{height}px;") : chart_js
        #output.html_safe   #does not work in rails 2.3.5 but should work in later ones
      end

      private
      def series_to_json(series, data_as_var = false)
        data_sets = []
        x_is_date, y_is_date = false, false
        i = 1
        series.each do |name, values|
          set, data = {}, []
          set[:label] = name
          first = values[:collection].first
          if first
            x_is_date = first.send(values[:x]).acts_like?(:date) || first.send(values[:x]).acts_like?(:time)
            y_is_date = first.send(values[:y]).acts_like?(:date) || first.send(values[:y]).acts_like?(:time)
          end
          values[:collection].each do |object|
            x_value, y_value = object.send(values[:x]), object.send(values[:y])
            x = x_is_date ? x_value.to_time.to_i * 1000 : x_value.to_f
            y = y_is_date ? y_value.to_time.to_i * 1000 : y_value.to_f
            data << [x,y]
          end
          set[:data] = data_as_var ? "d#{i.to_s}" : data
          values[:options].each {|option, parameters| set[option] = parameters } if values[:options]
          data_sets << set
          i += 1
        end
        return happy_js(data_sets.to_json), x_is_date, y_is_date
      end
      
      def happy_js(output)        
        while output  =~ /"data":"[\w]+"/
          output.sub!(/"data":"[\w]+"/, $&.gsub('"', ' '))
        end
        output
      end
      
      def get_vars(vars, x_is_date, y_is_date)
        data_sets = []
        i = 1
        vars.each do |lable, values|
          set, data = {}, []
          set[:name] = "d#{i.to_s}"
          values[:collection].each do |object|
            x_value, y_value = object.send(values[:x]), object.send(values[:y])
            x = x_is_date ? x_value.to_time.to_i * 1000 : x_value.to_f
            y = y_is_date ? y_value.to_time.to_i * 1000 : y_value.to_f
            data << [x,y]
          end
          set[:data] = data
#          values[:options].each {|option, parameters| set[option] = parameters } if values[:options]
          data_sets << set
          i=i+1
        end
        return data_sets  #[{:name, :data}, {,},{,}]
      end
      def tool_tip_script(plot_div)
        t ="\n      function showTooltip(x, y, contents) {"
        t+="\n        $('<div id=\"tooltip\">' + contents + '</div>').css( {"
        t+="\n          position: 'absolute',"
        t+="\n          display: 'none',"
        t+="\n          top: y + 5,"
        t+="\n          left: x + 5,"
        t+="\n          border: '1px solid #fdd',"
        t+="\n          padding: '2px',"
        t+="\n          'background-color': '#fee',"
        t+="\n          opacity: 0.80"
        t+="\n        }).appendTo(\"body\").fadeIn(200);"
        t+="\n      }"
        t+="\n      "
        t+="\n      var previousPoint = null;"
        t+="\n      $(\"##{plot_div}\").bind(\"plothover\", function (event, pos, item) {"
        t+="\n        $(\"#x\").text(pos.x.toFixed(2));"
        t+="\n        $(\"#y\").text(pos.y.toFixed(2));"
        t+="\n      "
        t+="\n          if (item) {"
        t+="\n             if (previousPoint != item.datapoint) {"
        t+="\n               previousPoint = item.datapoint;"
        t+="\n    "
        t+="\n                 $(\"#tooltip\").remove();"
        t+="\n                 var x = item.datapoint[0].toFixed(2),"
        t+="\n                     y = item.datapoint[1].toFixed(2);"
        t+="\n    "
        t+="\n                  showTooltip(item.pageX, item.pageY,"
        t+="\n                              item.series.label + \" of \" + x + \" = \" + y);"
        t+="\n             }"
        t+="\n          }"
        t+="\n         else {"
        t+="\n             $(\"#tooltip\").remove();"
        t+="\n             previousPoint = null;"
        t+="\n         }"  
        t+="\n      });"
        return t
      end

    end
  end
end

