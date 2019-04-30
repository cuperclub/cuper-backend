json.offices do
  json.array!(
    offices,
    partial: "api/shared/office",
    as: :office
  )
end
