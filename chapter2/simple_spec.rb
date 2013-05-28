require_relative 'simple'
class ValueExpression
  def ==(other)
    self.value == other.value
  end
end

describe "the simple language" do
  it "allows adding numbers" do
    Machine.new(
      Add.new(Number.new(1), Number.new(2))
    ).run.should eq(Number.new(3))
  end

  it "allows nested expressions" do
    Machine.new(
      Add.new(
        Multiply.new(Number.new(1), Number.new(2)),
        Multiply.new(Number.new(3), Number.new(4))
      )
    ).run.should eq(Number.new(14))
  end

  it "allows comparisons" do
    Machine.new(
      LessThan.new(Number.new(5), Number.new(4))
    ).run.should eq(Boolean.new(false))
  end

  it "allows comparison of nested expressions" do
    Machine.new(
      LessThan.new(Number.new(5), Add.new(Number.new(6), Number.new(2)))
    ).run.should eq(Boolean.new(true))
  end

  context "with an environment" do
    let(:environment) do
      {x: Number.new(3),
       y: Number.new(4)}
    end

    it "allows expressions with variables" do
      Machine.new(
        Add.new(Variable.new(:x), Variable.new(:y)),
        environment
      ).run.should eq(Number.new(7))
    end

    it "allows assignment" do
      Machine.new(
        Assign.new(:x, Add.new(Variable.new(:x), Number.new(1))),
        environment
      ).run.environment.should eq({x: Number.new(4), y: Number.new(4)})
    end

    it "allows conditionals" do
       Machine.new(
         If.new(
           Variable.new(:x),
           Assign.new(:y, Number.new(1)),
           Assign.new(:y, Number.new(2))
           ),
         { x: Boolean.new(true) }
       ).run.environment[:y].should eq(Number.new(1))


       Machine.new(
         If.new(
           Variable.new(:x),
           Assign.new(:y, Number.new(1)),
           Assign.new(:y, Number.new(2))
           ),
         { x: Boolean.new(false) }
       ).run.environment[:y].should eq(Number.new(2))
    end

    it "allows sequences of expressions" do
      Machine.new(
        Sequence.new(
          Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
          Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
          ),
          {}
      ).run.environment.should eq({x: Number.new(2), y: Number.new(5)})
    end


    it "allows nested sequences" do
      Machine.new(
        Sequence.new(
          Sequence.new(
            Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
            Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
            ),
          Add.new(Variable.new(:x), Variable.new(:y))
        ),
        {}
      ).run.should eq(Number.new(7))
    end

    it "allows looping" do
      Machine.new(
        While.new(
            LessThan.new(Variable.new(:x), Number.new(5)),
            Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
          ),
          { x: Number.new(1) }
      ).run.environment.should eq({x: Number.new(9)})
    end
  end
end
