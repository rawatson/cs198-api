require "test_helper"

describe ParamsHelper do
  describe :coerce_boolean_strings do
    params = {
      true_param: "true",
      false_param: "false",
      numeric_param: 25,
      string_param: "hello world",
      list_param: [true, false],
      boolean_param: true
    }

    it "must coerce boolean parameters" do
      coerced_params = coerce_boolean_strings params

      coerced_params[:true_param].must_equal true
      coerced_params[:false_param].must_equal false
    end

    it "must not coerce non-boolean parameters" do
      coerced_params = coerce_boolean_strings params

      [:numeric_param, :string_param, :list_param, :boolean_param].each do |p|
        coerced_params[p].must_equal params[p]
      end
    end
  end
end
