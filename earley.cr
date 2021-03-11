require "set"

class Production
  property terms

  @terms: Array(String | Rule) | Array(String) | Array(Rule)

  def initialize(*terms);
    @terms = terms.to_a
  end
end

class Rule
  property name, productions
  
  @name: Symbol | String
  @productions:  Array(Production)

  def initialize(@name, *productions);
    @productions = productions.to_a
  end

  def parse(text)
    table = text.chars.map_with_index { |ch, i| Column.new i, ch }
    table[0].add State.new :gamma, Production.new(self), 0, table[0]

    table.each.with_index do |col, i|
      col.each do |state|
        if state.completed?
          col.complete state
        else
          term = state.next_term
          if !term.nil?
            col.predict state
          elsif i + 1 < table.size
            table[i + 1].scan state, term
          end
        end
      end
    end

    if gamma = table[-1].states.find {|state| state.name == :gamma && state.completed? }
      gamma
    else
      raise Exception.new "ERROR WHILE PARSING"
    end
  end

  def add(productions)
    @productions << productions.dup
  end
end

class State  
  property name, production, pos, start_column, end_column, productions

  def rules
    @productions.select {|prod| prod.is_a? Rule}
  end

  @name : String | Symbol
  @production : Production
  @pos : Int32
  @start_column : Column
  @end_column : Column?
  @productions = [] of Production

  def initialize(@name, @production, @pos, @start_column); end

  def completed?
    @pos >= @productions.size
  end

  def next_term
    unless self.completed?
      @production.terms[@pos]
    end
  end

  private def build(children : Array(Node), state : State, rule_index : Int32, end_column : Column | Nil)
    case rule_index
    when ...0
      return [Node.new(state, children)]
    when 0
      start_column = state.start_column
    else
      start_column = nil
    end

    rule = state.rules[rule_index]
    end_column.not_nil!
      .take_while { |st| st != state }
      .select { |st| !st.completed? || !start_column.nil? && start_column != st.start_column }
      .flat_map { |st|
        st.build_trees.flat_map { |sub_tree|
          build [sub_tree] + children, state, rule_index - 1, st.start_column
        }
      }
  end

  def build_trees : Array(Node)
    build [] of Node, self.itself, @productions.size - 1, @end_column
  end
end

class Column
  include Enumerable(State)

  property index, token, states, unique

  @index : Int32
  @token : Char
  @states = [] of State
  @unique = Set(State).new

  def each
    @states.each do |state|
      yield state
    end
  end

  def initialize(@index, @token); end

  def add(state)
    unless @states.includes? state
      @unique.add state
      state.end_column = self
      @states << state
      return true
    end
    return false
  end

  def predict(rule)
    rule.productions.each { |prod| self.add State.new rule.name, prod, 0, self }
  end

  def scan(state, token)
    if @token == token
      self.add State.new state.name, state.production, state.pos + 1, state.start_column
    end
  end

  def complete(state)
    unless state.completed?
      state.start_column.each do |st|
        if (term = st.next_term) && term.is_a? Rule  && st.name == term.name
          st = state.dup
          st.end_column = nil
          self.add st
        end
      end
    end
  end
end

class Node
  @value : State
  @children : Array(Node)

  def initialize(@value, @children); end
end

a = Rule.new "a", Production.new "a"
op = Rule.new "op", Production.new "+"
expr = Rule.new "expr", Production.new a
expr.add Production.new a, a

pp expr
pp expr.parse("a  ").build_trees