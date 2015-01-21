module QuestionsHelper

  def display_options ques
    if ques
      field = ques.question_type
      ["dropdown","dropdown_with_other", "dropdown_with_multiple_select", "branch_field", "file_upload"].include? field
    end
  end

  def answer_options ques
    ques[:answer_options].to_a.join(", ") if (ques and ques[:answer_options].present?)
  end

  def get_field_id ques, i
    "#{ques.id}-#{i+1}"
  end

  def order_sequence
    arr = []
    @questions.where(:created_at.ne => nil).entries.each_with_index{|q, i| arr << "#{q.id}-#{i+1}"}
    arr.join(",")
  end
  
  def ques_type
   ["text","text-area","dropdown","dropdown_with_other", "dropdown_with_multiple_select", "branch_field","numerical"]
 end
end