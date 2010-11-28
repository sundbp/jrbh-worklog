module ApplicationHelper
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
    output = "<script type='text/javascript'>\n\t$.farbtastic('##{colorpicker}').enable();\n"
    output << "\t$('##{colorpicker}').css('display', 'block')\n"
    output << "</script>\n"
  end

  def farbtastic_disable(colorpicker)
    output = "<script type='text/javascript'>\n\t$.farbtastic('##{colorpicker}').disable();\n"
    output << "\t$('##{colorpicker}').css('display', 'none')\n"
    output << "</script>\n"
  end

  def farbtastic_set_color(colorpicker, color)
    "<script type='text/javascript'>\n\t$.farbtastic('##{colorpicker}').setColor(color);\n</script>\n"
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

  class WorklogTaskGroup
    attr_reader :group_name, :options
    def initialize(name)
      @group_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end

    def <=>(other)
      return @group_name <=> other.group_name
    end
  end

  WorklogTaskGroupOption = Struct.new(:id, :name)

  def task_groups_options(only_visible = true)
    result = Hash.new
    worklog_tasks = if only_visible
      WorklogTask.visible_in_user_menus
    else
      WorklogTask.all
    end
    worklog_tasks.each do |t|
      result[t.company.name] = WorklogTaskGroup.new(t.company.name) unless result.has_key? t.company.name
      result[t.company.name] << WorklogTaskGroupOption.new(t.id, t.name)
    end
    result.values.sort
  end


end
