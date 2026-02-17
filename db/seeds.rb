require "faker"

puts "Seeding database…"

# ---------------------------------------------------------------------------
# Companies
# ---------------------------------------------------------------------------
company_data = [
  { name: "Acme Corp",         website: "https://acme.example.com" },
  { name: "Globex Industries",  website: "https://globex.example.com" },
  { name: "Initech",           website: "https://initech.example.com" },
  { name: "Umbrella LLC",      website: "https://umbrella.example.com" },
  { name: "Stark Ventures",    website: "https://stark.example.com" },
]

companies = company_data.map do |attrs|
  Company.find_or_create_by!(name: attrs[:name]) do |c|
    c.website = attrs[:website]
  end
end
puts "  #{companies.size} companies"

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------
tag_data = [
  { name: "Customer",  color: "#10b981" },
  { name: "Prospect",  color: "#3b82f6" },
  { name: "VIP",       color: "#8b5cf6" },
  { name: "Internal",  color: "#6366f1" },
  { name: "Vendor",    color: "#f59e0b" },
  { name: "Friend",    color: "#ec4899" },
  { name: "Investor",  color: "#14b8a6" },
  { name: "Partner",   color: "#f97316" },
]

tags = tag_data.map do |attrs|
  Tag.find_or_create_by!(name: attrs[:name]) do |t|
    t.color = attrs[:color]
  end
end
puts "  #{tags.size} tags"

# ---------------------------------------------------------------------------
# Contacts (30 total; 3 archived, several starred)
# ---------------------------------------------------------------------------
contact_list = [
  { first_name: "Alice",   last_name: "Johnson",   email: "alice.johnson@acme.example.com",       phone: "+1-555-0101", company: companies[0], starred: true },
  { first_name: "Bob",     last_name: "Williams",  email: "bob.williams@globex.example.com",      phone: "+1-555-0102", company: companies[1] },
  { first_name: "Carol",   last_name: "Davis",     email: "carol.davis@initech.example.com",      phone: "+1-555-0103", company: companies[2], starred: true },
  { first_name: "David",   last_name: "Martinez",  email: "david.martinez@umbrella.example.com",  phone: "+1-555-0104", company: companies[3] },
  { first_name: "Eve",     last_name: "Anderson",  email: "eve.anderson@stark.example.com",       phone: "+1-555-0105", company: companies[4], starred: true },
  { first_name: "Frank",   last_name: "Thomas",    email: "frank.thomas@acme.example.com",        phone: "+1-555-0106", company: companies[0] },
  { first_name: "Grace",   last_name: "Jackson",   email: "grace.jackson@globex.example.com",     phone: "+1-555-0107", company: companies[1] },
  { first_name: "Henry",   last_name: "White",     email: "henry.white@initech.example.com",      phone: "+1-555-0108", company: companies[2], starred: true },
  { first_name: "Iris",    last_name: "Harris",    email: "iris.harris@umbrella.example.com",     phone: "+1-555-0109", company: companies[3] },
  { first_name: "Jack",    last_name: "Lewis",     email: "jack.lewis@stark.example.com",         phone: "+1-555-0110", company: companies[4] },
  { first_name: "Kate",    last_name: "Clark",     email: "kate.clark@acme.example.com",          phone: "+1-555-0111", company: companies[0], starred: true },
  { first_name: "Leo",     last_name: "Walker",    email: "leo.walker@globex.example.com",        phone: "+1-555-0112", company: companies[1] },
  { first_name: "Maya",    last_name: "Hall",      email: "maya.hall@initech.example.com",        phone: "+1-555-0113", company: companies[2] },
  { first_name: "Nathan",  last_name: "Allen",     email: "nathan.allen@umbrella.example.com",    phone: "+1-555-0114", company: companies[3] },
  { first_name: "Olivia",  last_name: "Young",     email: "olivia.young@stark.example.com",      phone: "+1-555-0115", company: companies[4], starred: true },
  { first_name: "Peter",   last_name: "King",      email: "peter.king@acme.example.com",          phone: "+1-555-0116", company: companies[0] },
  { first_name: "Quinn",   last_name: "Wright",    email: "quinn.wright@globex.example.com",      phone: "+1-555-0117", company: companies[1] },
  { first_name: "Rachel",  last_name: "Scott",     email: "rachel.scott@initech.example.com",     phone: "+1-555-0118", company: companies[2] },
  { first_name: "Sam",     last_name: "Green",     email: "sam.green@umbrella.example.com",       phone: "+1-555-0119", company: companies[3], starred: true },
  { first_name: "Tara",    last_name: "Baker",     email: "tara.baker@stark.example.com",         phone: "+1-555-0120", company: companies[4] },
  { first_name: "Uma",     last_name: "Adams",     email: "uma.adams@acme.example.com",           phone: "+1-555-0121", company: companies[0] },
  { first_name: "Victor",  last_name: "Nelson",    email: "victor.nelson@globex.example.com",     phone: "+1-555-0122", company: companies[1] },
  { first_name: "Wendy",   last_name: "Carter",    email: "wendy.carter@initech.example.com",     phone: "+1-555-0123", company: companies[2], starred: true },
  { first_name: "Xander",  last_name: "Mitchell",  email: "xander.mitchell@umbrella.example.com", phone: "+1-555-0124", company: companies[3] },
  { first_name: "Yara",    last_name: "Perez",     email: "yara.perez@stark.example.com",         phone: "+1-555-0125", company: companies[4] },
  { first_name: "Zoe",     last_name: "Roberts",   email: "zoe.roberts@acme.example.com",         phone: "+1-555-0126", company: companies[0], starred: true },
  # Archived contacts
  { first_name: "Aaron",   last_name: "Turner",    email: "aaron.turner@globex.example.com",      phone: "+1-555-0127", company: companies[1], archived_at: 3.weeks.ago },
  { first_name: "Beth",    last_name: "Phillips",  email: "beth.phillips@initech.example.com",    phone: "+1-555-0128", company: companies[2], archived_at: 2.months.ago },
  { first_name: "Cole",    last_name: "Campbell",  email: "cole.campbell@umbrella.example.com",   phone: "+1-555-0129", company: companies[3], archived_at: 1.month.ago },
  { first_name: "Dana",    last_name: "Parker",    email: "dana.parker@stark.example.com",        phone: "+1-555-0130", company: companies[4], archived_at: 6.weeks.ago },
]

notes_samples = [
  "Met at the 2024 SaaS Summit. Very interested in our enterprise plan.",
  "Referred by Kate Clark. Highly responsive and technical.",
  "Prefers calls on Tuesday afternoons. Main decision-maker.",
  "Evaluating competitors. Plan to follow up end of quarter.",
  "Long-term customer since 2019. Advocates for us internally.",
  "Introduced via LinkedIn. Exploring a partnership opportunity.",
]

contacts = contact_list.map do |attrs|
  contact = Contact.find_or_create_by!(email: attrs[:email]) do |c|
    c.first_name  = attrs[:first_name]
    c.last_name   = attrs[:last_name]
    c.phone       = attrs[:phone]
    c.company     = attrs[:company]
    c.starred     = attrs[:starred] || false
    c.archived_at = attrs[:archived_at]
    c.notes       = notes_samples.sample
  end
  contact
end
puts "  #{contacts.size} contacts"

# ---------------------------------------------------------------------------
# Tags (2–3 per contact)
# ---------------------------------------------------------------------------
contacts.each do |contact|
  next if contact.tags.count >= 2
  tags.sample(rand(2..3)).each do |tag|
    ContactTag.find_or_create_by!(contact: contact, tag: tag)
  end
end
puts "  Tags assigned"

# ---------------------------------------------------------------------------
# Activities (3–5 per contact)
# ---------------------------------------------------------------------------
activity_bodies = {
  "note"  => [
    "Discussed pricing options for the enterprise tier.",
    "Sent over the product roadmap deck.",
    "Left a voicemail — will follow up on the proposal.",
    "Reviewed contract terms together over a video call.",
    "Introduced to our engineering team.",
    "They requested a custom demo environment.",
  ],
  "call"  => [
    "30-minute intro call — very positive energy.",
    "Quarterly check-in. Very happy with the product.",
    "Called to follow up on the open support ticket.",
    "Discovery call — identified 3 key pain points.",
    "Called to confirm next week's on-site meeting.",
  ],
  "email" => [
    "Sent proposal with three pricing tiers.",
    "Forwarded the security questionnaire.",
    "Shared the onboarding guide PDF.",
    "Emailed the updated contract draft for review.",
    "Sent recap of our kickoff meeting.",
    "Emailed intro to the dedicated support team.",
  ],
}

contacts.each do |contact|
  next if contact.activities.count >= 3
  rand(3..5).times do
    kind = Activity::KINDS.sample
    contact.activities.create!(
      kind:       kind,
      body:       activity_bodies[kind].sample,
      created_at: rand(1..90).days.ago
    )
  end
end
puts "  Activities created"

puts "Done! #{Contact.count} contacts, #{Company.count} companies, #{Tag.count} tags."
