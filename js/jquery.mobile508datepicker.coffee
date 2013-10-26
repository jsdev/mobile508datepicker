#
#	Author: @jsdev | Anthony Delorie June 2013
#	Github: https://github.com/jsdev/mobile508datepicker
#	MIT License: as is, feel free to fork =)
#	Tested on: IOS, Android, Surface, Modern Browsers, IE10+, IE9
# 
(($) ->
  "use strict"
  $.fn.extend
    mobile508datepicker: (options) ->
      currentDate = new Date()
      _defaults =
        MIN: new Date(new Date().setFullYear(currentDate.getFullYear() - 10)) # years ago
        MAX: new Date(new Date().setFullYear(currentDate.getFullYear() + 10)) # years ahead

      defaults = null
      
      #jshint multistr: true 
      $el = $("<section class=\"datetime-picker\" id=\"date-picker\" data-role=\"popup\" data-dismissible=\"false\" data-overlay-theme=\"a\"> \t\t\t\t\t<a href=\"#\" data-rel=\"back\" data-role=\"button\" data-theme=\"a\" data-icon=\"delete\" data-iconpos=\"notext\" class=\"ui-btn-right cancel\">Close</a> \t\t\t\t\t<h1 class=\"ui-title\" role=\"heading\" aria-level=\"1\" class=\"date\">Today</h1> \t\t\t\t\t<div class=\"columns\"><b class=\"month\"><ul></ul></b><b class=\"day\"><ul></ul></b><b class=\"year\"><ul></ul></b></div> \t\t\t\t\t<button id=\"set-btn\" data-theme=\"b\" class=\"ui-btn-hidden\" data-disabled=\"false\">SET</button> \t\t\t\t\t</section>")
      buildEl = ->
        $("body").append $el
        $el.trigger "create"
        $el.popup()
        $el

      $textbox = null
      parseDate = (dateObj) ->
        d = (if typeof dateObj is "number" then new Date(dateObj) else dateObj)
        year: d.getFullYear()
        month: d.getMonth()
        day: d.getDate()

      toggleButtons = (y, m, $d, $m, className) ->
        $disabled = $el.find("." + className + ":disabled")
        $disabled.prop "disabled", false
        if y is dateChosen.year
          if m is dateChosen.month
            $d.prop("disabled", true).addClass className
          else
            $disabled.prop "disabled", false
          $m.prop("disabled", true).addClass className

      TODAY = parseDate(currentDate)
      dateChosen = null
      DATE_MAX = null
      DATE_MIN = null
      MONTHS = [
        "JAN"
        "FEB"
        "MAR"
        "APR"
        "MAY"
        "JUN"
        "JUL"
        "AUG"
        "SEP"
        "OCT"
        "NOV"
        "DEC"
      ]
      WEEKDAYS = [
        "Su "
        "Mo "
        "Tu "
        "We "
        "Th "
        "Fr "
        "Sa "
      ]
      
      #WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      buildDOM = ->
        i = undefined
        len = undefined
        frag = []
        i = 1
        while i < 10
          frag.push "<li><button data-value=\"" + i + "\">0" + i + "</button></li>"
          i++
        i = 10
        while i <= 31
          frag.push "<li><button data-value=\"" + i + "\">" + i + "</button></li>"
          i++
        $day.html frag.join("")
        $days = $day.children()
        i = DATE_MIN.year
        frag = []
        len = DATE_MAX.year

        while i <= len
          frag.push "<li><button data-value=\"" + i + "\">" + i + "</button></li>"
          i++
        $year.html frag.join("")
        i = 0
        frag = []
        len = MONTHS.length

        while i < len
          frag.push "<li><button data-value=\"" + i + "\">" + MONTHS[i] + "</button></li>"
          i++
        $month.html frag.join("")

      checkMax = ->
        d = DATE_MAX.day
        m = DATE_MAX.month
        y = DATE_MAX.year
        $m = $month.find("button").slice(m + 1, 12)
        $d = $day.find("button").slice(d, 31)
        toggleButtons y, m, $d, $m, "too-soon"

      checkMin = ->
        d = DATE_MIN.day
        m = DATE_MIN.month
        y = DATE_MIN.year
        $m = $month.find("button").slice(0, m)
        $d = $day.find("button").slice(0, d - 1)
        toggleButtons y, m, $d, $m, "too-late"

      baseLine = ->
        $(".too-soon").prop("disabled", false).removeClass "too-soon"
        $(".too-late").prop("disabled", false).removeClass "too-late"

      daysInMonth = ->
        new Date(dateChosen.year, 1 + dateChosen.month, 0).getDate()

      upDate = (typ) ->
        setDate()
        typ and typ isnt "day" and checkDays()
        $(".selected").removeAttr "class"
        $year.find("[data-value=\"" + dateChosen.year + "\"]").add($day.find("[data-value=\"" + dateChosen.day + "\"]")).add($month.find("[data-value=\"" + dateChosen.month + "\"]")).addClass("selected").scrollTopMe()
        updateHeading()
        typ and typ isnt "day" and baseLine()
        checkMin()
        checkMax()

      updateHeading = ->
        calcDate = setDate()
        
        #$setBtn.prev('span').find('span').text('Set as: ' + [dateChosen.month+1, dateChosen.day, dateChosen.year].join('/'));
        heading.innerHTML = (if calcDate.toDateString() is currentDate.toDateString() then "Today" else WEEKDAYS[calcDate.getDay()])

      checkDays = ->
        _daysInMonth = daysInMonth()
        len = $days.length
        i = undefined
        calcDate = undefined
        $days.show()
        i = 0
        while i < len
          calcDate = new Date([
            dateChosen["month"]
            i + 1
            dateChosen["year"]
          ].join("/"))
          i++
        i = _daysInMonth
        while i < len
          $days.eq(i).hide()
          i++
        dateChosen["day"] = _daysInMonth  if dateChosen["day"] > _daysInMonth

      clicked = ($this) ->
        $li = $this.focus().parent()
        $ul = $li.parent()
        $focused = $(":focus")
        typ = undefined
        if not $this.length or $this.prop("disabled")
          $focused.focus()
          return false
        typ = $ul.parent()[0].className
        dateChosen[typ] = $this.data("value")
        upDate typ
        true

      setDate = ->
        d = new Date(dateChosen.year, dateChosen.month, dateChosen.day)
        MAX = defaults.MAX
        MIN = defaults.MIN
        if MAX and d > MAX
          $.extend dateChosen, DATE_MAX
          return new Date(dateChosen.year, dateChosen.month, dateChosen.day)
        if MIN and d < MIN
          $.extend dateChosen, DATE_MIN
          return new Date(dateChosen.year, dateChosen.month, dateChosen.day)
        d

      scrolled = ($ul) ->
        $lis = $ul.children()
        lineHeight = $lis.eq(0).height()
        top = $ul.position().top
        n = Math.round(-top / lineHeight)
        $buttons = $ul.find("button")
        $button = $lis.eq(n).find("button")
        $prevSelected = $ul.find(".selected")
        prevSelectedIndex = $buttons.index($prevSelected)
        typ = $ul.parent()[0].className
        unless $button.prop("disabled")
          return  if prevSelectedIndex is n
          $ul.scrollTop (-n * lineHeight) + lineHeight
          dateChosen[typ] = $button.data()["value"]
          upDate typ
          return
        $button = $ul.find("button:enabled").eq((if prevSelectedIndex > n then 0 else -1))
        n = $buttons.index($button)
        $ul.scrollTop (-n * lineHeight) + lineHeight
        dateChosen[typ] = $button.data()["value"]
        upDate typ
        return

      alignValidDate = ->
        $uls = $el.find("ul")
        $ul = undefined
        $lis = undefined
        lineHeight = undefined
        $button = undefined
        $buttons = undefined
        top = undefined
        n = undefined
        orderSet = [
          1
          0
          2
        ]
        while orderSet.length
          $ul = $uls.eq(orderSet.pop())
          $buttons = $ul.find("button")
          $lis = $ul.children()
          lineHeight = $lis.eq(0).height()
          top = $ul.position().top
          n = Math.round(-top / lineHeight)
          $button = $lis.eq(n).find("button")
          n = $buttons.index($button)
          $ul.scrollTop -n * lineHeight
          dateChosen[$ul.parent()[0].className] = $button.data()["value"]
          upDate()

      destroy = ->
        dateChosen = null
        DATE_MAX = null
        DATE_MIN = null

      validateMinMax = ->
        if defaults.MIN > defaults.MAX
          temp = defaults.MIN
          defaults.MIN = defaults.MAX
          defaults.MAX = temp

      close = ->
        destroy()
        $el.popup "close"
        defaults.onClose()  if defaults.onClose
        $textbox.focus()

      init = ->
        val = $textbox.val()
        dateChosen = (if val.length then parseDate(new Date(val)) else $.extend({}, TODAY))
        validateMinMax()
        defaults.MIN = (if defaults.afterToday then new Date() else defaults.MIN)
        defaults.MAX = (if defaults.beforeToday then new Date() else defaults.MAX)
        DATE_MIN = parseDate(defaults.MIN)
        DATE_MAX = parseDate(defaults.MAX)
        buildDOM()
        upDate()
        $el.find(".selected").eq(0).focus()
        $el.popup()

      $year = $el.find(".year ul")
      $month = $el.find(".month ul")
      $day = $el.find(".day ul")
      $cancel = $el.find(".cancel")
      $setBtn = $el.find("#set-btn")
      $days = null
      heading = $el.find("h1")[0]
      $.extend _defaults, options
      $el.find(".month").on "scrollstop", (e) ->
        scrolled $(e.currentTarget).find("ul")

      $el.find(".day").on "scrollstop", (e) ->
        scrolled $(e.currentTarget).find("ul")

      $el.find(".year").on "scrollstop", (e) ->
        scrolled $(e.currentTarget).find("ul")

      #prevents scroll
      $el.on("click", "#set-btn", ->
        m = dateChosen.month + 1
        d = dateChosen.day
        y = dateChosen.year
        if defaults["leading-zero"]
          m = ("0" + m).substr(-2)
          d = ("0" + d).substr(-2)
        alignValidDate()
        $textbox.val [
          m
          d
          y
        ].join("/")
        close()
      ).on("keydown", "#set-btn", (e) ->
        e.preventDefault()
        switch e.which
          when 9
            if e.shiftKey
              $(".selected").eq(2).focus()
            else
              $cancel.focus()
          when 13
            e.currentTarget.click()
      ).on("click", "b button", (e) ->
        clicked $(e.currentTarget)
      ).on("keydown", "b", (e) ->
        $this = $(e.currentTarget)
        tab = (dir) ->
          ifPossible = $this[dir]("b").find(".selected").length
          if ifPossible
            $this[dir]("b").find(".selected").focus()
            return
          switch dir
            when "prev"
              $cancel.focus()
            when "next"
              $setBtn.focus()

        ifPossible = (dir) ->
          $possible = $this.find(".selected").parents("li")[dir]("li").find("button")
          clicked $possible  if $possible.length and not $possible.prop("disabled")

        e.preventDefault()
        switch e.which
          when 9
            if e.shiftKey
              tab "prev"
            else
              tab "next"
          when 37
            tab "prev"
          when 38
            ifPossible "prev"
          when 39
            tab "next"
          when 40
            ifPossible "next"
      ).on("keydown", ".cancel", (e) ->
        e.preventDefault()
        switch e.which
          when 9
            if e.shiftKey
              $setBtn.focus()
            else
              $(".month .selected").focus()
          when 13
            e.currentTarget.click()
      ).on("click", ".cancel", (e) ->
        e.preventDefault()
        close()
      ).on "keydown", (e) ->
        close()  if e.which is 27

      
      #Iterate over the current set of matched elements
      @each ->
        $this = $(this)
        $dp = $("#date-picker")
        
        #THIS WILL BUILD IT ONCE, vs. only once foreach in collection
        $dp.length or buildEl()
        $this.on("click", (e) ->
          $(".ui-popup-active .ui-popup").popup "close"
          $textbox = $(e.currentTarget)
          defaults = $.extend({}, _defaults)
          $.extend defaults, $textbox.data("options")
          init()
          $el.popup "open"
        ).on "keydown", (e) ->
          EnterOrNumberKeys = [
            13
            48
            49
            50
            51
            52
            53
            54
            55
            56
            57
          ]
          e.currentTarget.click()  if EnterOrNumberKeys.indexOf(e.which) + 1



    scrollTopMe: ->
      @each ->
        $li = $(this).parent()
        $ul = $li.parent()
        $b = $ul.parent()
        scrollTop = $ul.children().index($li) * $li.height()
        $b.scrollTop scrollTop


) jQuery
