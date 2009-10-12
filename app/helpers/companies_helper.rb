module CompaniesHelper
  def farbtastic_create (colorpicker, color_field, editable=false)
    output = sprintf("<script type='text/javascript'>\n\t$('#%s').farbtastic('#%s');\n", colorpicker, color_field )
    if editable then
      output << "\t$.farbtastic('##{colorpicker}').enable();\n"
      output << "\t$('##{colorpicker}').css('display', 'block')"
    else
      output << "\t$.farbtastic('##{colorpicker}').disable();\n"
      output << "\t$('##{colorpicker}').css('display', 'none')"
    end
    output << "</script>\n"
  end

  def farbtastic_enable(colorpicker)
    sprintf("<script type='text/javascript'>\n\t$.farbtastic('#%s').enable();\n</script>\n", colorpicker)
  end

  def farbtastic_disable(colorpicker)
    sprintf("<script type='text/javascript'>\n\t$.farbtastic('#%s').disable();\n</script>\n", colorpicker)
  end

  def color_id(object)
    sprintf( "farbtastic_color_%d", object.id)
  end

  def colorpicker_id(object)
    sprintf( "farbtastic_colorpicker_%d", object.id)
  end

  def colorpicker_div(args)
    # TODO: add an assert for not having an id!
    output = "<div "
    comma_flag = false
    args.each do |key, value|
      if comma_flag then
        output << sprintf(", %s='%s'", key.to_s, value )
      else
        output << sprintf("%s='%s'", key.to_s, value )
        comma_flag = true
      end
    end
    output << "></div>\n"
    return output
  end
end
