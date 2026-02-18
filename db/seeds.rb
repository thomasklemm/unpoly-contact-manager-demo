puts "Seeding database…"

# ---------------------------------------------------------------------------
# Companies
# ---------------------------------------------------------------------------
company_data = [
  { name: "Meridian Software",    website: "https://meridiansoftware.com" },
  { name: "Cobalt Labs",          website: "https://cobaltlabs.io" },
  { name: "Hartwell & Partners",  website: "https://hartwellpartners.com" },
  { name: "Vantage Capital",      website: "https://vantagecapital.vc" },
  { name: "Orion Health",         website: "https://orionhealth.com" },
  { name: "Pinecrest Media",      website: "https://pinecrestmedia.com" },
  { name: "Luminary Design",      website: "https://luminarydesign.co" },
  { name: "Cascade Analytics",    website: "https://cascadeanalytics.io" }
]

companies = company_data.map do |attrs|
  Company.find_or_create_by!(name: attrs[:name]) do |c|
    c.website = attrs[:website]
  end
end

meridian, cobalt, hartwell, vantage, orion, pinecrest, luminary, cascade = companies
puts "  #{companies.size} companies"

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------
tag_data = [
  { name: "Customer",  color: "#10b981" },
  { name: "Prospect",  color: "#3b82f6" },
  { name: "VIP",       color: "#8b5cf6" },
  { name: "Partner",   color: "#f97316" },
  { name: "Investor",  color: "#14b8a6" },
  { name: "Vendor",    color: "#f59e0b" },
  { name: "Friend",    color: "#ec4899" },
  { name: "Lead",      color: "#6366f1" }
]

tags = tag_data.map do |attrs|
  Tag.find_or_create_by!(name: attrs[:name]) do |t|
    t.color = attrs[:color]
  end
end

customer, prospect, vip, partner, investor, vendor, friend, lead = tags
puts "  #{tags.size} tags"

# ---------------------------------------------------------------------------
# Contacts
# ---------------------------------------------------------------------------
contact_list = [
  {
    first_name: "Sarah",    last_name: "Chen",
    email: "sarah.chen@meridiansoftware.com",       phone: "+1-415-555-0181",
    company: meridian,  starred: true,
    notes: "VP of Sales at Meridian. Met at SaaStr Annual last March — immediately clicked. She's the key champion for our enterprise deal and has executive buy-in. Prefers async comms; responds best to Slack.",
    tags: [ customer, vip ]
  },
  {
    first_name: "Marcus",   last_name: "Webb",
    email: "marcus.webb@cobaltlabs.io",             phone: "+1-628-555-0142",
    company: cobalt,    starred: true,
    notes: "CTO and co-founder of Cobalt Labs. Deep ML background from Google Brain. Very technical — skip the sales pitch, go straight to architecture discussions. Interested in our API. Intro'd by Fiona.",
    tags: [ customer, vip ]
  },
  {
    first_name: "Priya",    last_name: "Patel",
    email: "priya.patel@hartwellpartners.com",      phone: "+1-212-555-0167",
    company: hartwell,
    notes: "Strategy partner at Hartwell. Runs their tech practice. Has referred two clients our way this year. Very well-connected in the NY enterprise scene. Coffee whenever she's in SF.",
    tags: [ partner, customer ]
  },
  {
    first_name: "James",    last_name: "O'Brien",
    email: "james.obrien@vantagecapital.vc",        phone: "+1-650-555-0193",
    company: vantage,   starred: true,
    notes: "Managing Director at Vantage Capital. Led our Series A. Sits on our board — monthly 1:1s. Super well-connected in fintech and healthtech. Always asks sharp questions about NRR and expansion revenue.",
    tags: [ investor, vip ]
  },
  {
    first_name: "Leila",    last_name: "Nassar",
    email: "leila.nassar@orionhealth.com",          phone: "+1-617-555-0154",
    company: orion,
    notes: "Product Director at Orion Health. Evaluating us as a replacement for their legacy CRM. Has strict HIPAA requirements. Needs a custom data processing agreement before moving forward.",
    tags: [ prospect ]
  },
  {
    first_name: "Tom",      last_name: "Erikson",
    email: "tom.erikson@pinecrestmedia.com",        phone: "+1-323-555-0118",
    company: pinecrest,
    notes: "CEO of Pinecrest Media. Runs a lean team of ~40. Signed last fall and has been a strong reference customer. Loves the Slack integration. Occasionally posts about us on LinkedIn.",
    tags: [ customer ]
  },
  {
    first_name: "Nina",     last_name: "Rodriguez",
    email: "nina.rodriguez@luminarydesign.co",      phone: "+1-512-555-0137",
    company: luminary,  starred: true,
    notes: "Creative Director at Luminary. Incredible eye for detail — gave us brutally honest feedback on our redesign which we incorporated. Wants to co-author a case study about their workflow transformation.",
    tags: [ customer, friend ]
  },
  {
    first_name: "Owen",     last_name: "Blackwell",
    email: "owen.blackwell@cascadeanalytics.io",    phone: "+1-206-555-0129",
    company: cascade,
    notes: "Data Science Lead at Cascade. Uses us for client reporting pipelines. Very into the API and has built several internal integrations. Would be a great reference for technical buyers.",
    tags: [ customer ]
  },
  {
    first_name: "Fiona",    last_name: "Tran",
    email: "fiona.tran@cobaltlabs.io",              phone: "+1-628-555-0161",
    company: cobalt,    starred: true,
    notes: "CEO and co-founder of Cobalt Labs. Former Stripe PM. Incredibly sharp and moves fast. Introduced us to three portfolio companies of her investors. Currently on a Series B raise — worth staying close.",
    tags: [ customer, vip, friend ]
  },
  {
    first_name: "Daniel",   last_name: "Kowalski",
    email: "daniel.kowalski@meridiansoftware.com",  phone: "+1-415-555-0174",
    company: meridian,
    notes: "Senior AE at Meridian. Manages the day-to-day of their account. Very organized, sends meeting notes religiously. Good entry point for expansion opportunities within the account.",
    tags: [ customer ]
  },
  {
    first_name: "Amara",    last_name: "Osei",
    email: "amara.osei@orionhealth.com",            phone: "+1-617-555-0183",
    company: orion,
    notes: "Head of Marketing at Orion Health. Interested in our analytics exports for campaign attribution. Met her through Leila. Likely the economic buyer for a marketing-focused expansion seat.",
    tags: [ prospect, lead ]
  },
  {
    first_name: "Raj",      last_name: "Iyer",
    email: "raj.iyer@cascadeanalytics.io",          phone: "+1-206-555-0146",
    company: cascade,
    notes: "Software engineer at Cascade. Owen's right-hand on the integrations side. Filed several detailed bug reports — always actionable. Would be a great candidate for our developer advisory group.",
    tags: [ customer ]
  },
  {
    first_name: "Claire",   last_name: "Dubois",
    email: "claire.dubois@hartwellpartners.com",    phone: "+1-212-555-0122",
    company: hartwell,
    notes: "Strategy consultant at Hartwell. Specializes in go-to-market for B2B SaaS. Brilliant at competitive positioning. Had a long lunch at Balthazar last month — great conversation about the mid-market opportunity.",
    tags: [ partner, friend ]
  },
  {
    first_name: "Luke",     last_name: "Harrington",
    email: "luke.harrington@gmail.com",             phone: "+1-650-555-0109",
    company: nil,       starred: true,
    notes: "Angel investor and advisor. 2x founder (SalesHero acquired by HubSpot, Relay acquired by Twilio). Invested $250K in our seed. Incredibly well-networked — sends warm intros regularly. Catch up monthly over coffee.",
    tags: [ investor, friend ]
  },
  {
    first_name: "Mia",      last_name: "Fernandez",
    email: "mia.fernandez@luminarydesign.co",       phone: "+1-512-555-0158",
    company: luminary,
    notes: "Senior UX designer at Luminary. Nina's collaborator on the case study. Shared a detailed teardown of our product's onboarding flow — three pages of notes. Feedback was gold.",
    tags: [ customer, friend ]
  },
  {
    first_name: "Ben",      last_name: "Nakamura",
    email: "ben.nakamura@pinecrestmedia.com",       phone: "+1-323-555-0135",
    company: pinecrest,
    notes: "Growth lead at Pinecrest. Manages their attribution stack. Very data-driven — loves dashboards. Exploring expanding their license from 10 to 30 seats after Q1 results came in strong.",
    tags: [ customer, prospect ]
  },
  {
    first_name: "Sofia",    last_name: "Andersen",
    email: "sofia.andersen@vantagecapital.vc",      phone: "+1-650-555-0177",
    company: vantage,
    notes: "Chief of Staff to James O'Brien at Vantage. Coordinates portfolio company check-ins and board prep. Super responsive, keeps everything moving. Good first contact when James is traveling.",
    tags: [ investor ]
  },
  {
    first_name: "Ethan",    last_name: "Blake",
    email: "ethan.blake@meridiansoftware.com",      phone: "+1-415-555-0163",
    company: meridian,
    notes: "DevOps engineer at Meridian. Leads their infrastructure migration project which uses our platform heavily. Filed a security questionnaire last month — in review with our team. Very thorough.",
    tags: [ customer ]
  },
  {
    first_name: "Zara",     last_name: "Ahmed",
    email: "zara.ahmed@cobaltlabs.io",              phone: "+1-628-555-0119",
    company: cobalt,
    notes: "Product manager at Cobalt. Runs the sprint process and owns the integration roadmap. Very organized — uses Notion extensively. Working with Marcus on the API roadmap alignment.",
    tags: [ customer ]
  },
  {
    first_name: "Chris",    last_name: "Park",
    email: "chris.park@cascadeanalytics.io",        phone: "+1-206-555-0141",
    company: cascade,   starred: true,
    notes: "VP of Sales at Cascade. Strong relationship built over 18 months. Referred us to four companies, three of which converted. Loves our enterprise dashboard — uses it daily. Evangelizes us at every opportunity.",
    tags: [ customer, vip, partner ]
  },
  {
    first_name: "Helen",    last_name: "Wu",
    email: "helen.wu@orionhealth.com",              phone: "+1-617-555-0196",
    company: orion,
    notes: "CFO at Orion Health. Joined the procurement conversation once the deal exceeded $50K ACV. Very focused on ROI metrics and data security. Needs a custom BAA and SSO before signing.",
    tags: [ prospect ]
  },
  {
    first_name: "Drew",     last_name: "Sullivan",
    email: "drew.sullivan@pinecrestmedia.com",      phone: "+1-323-555-0152",
    company: pinecrest,
    notes: "Content strategist at Pinecrest. Uses our platform for editorial workflow tracking. Super creative thinker. Left a glowing G2 review last quarter — worth reaching out for a testimonial video.",
    tags: [ customer, friend ]
  },
  {
    first_name: "Tanya",    last_name: "Morozova",
    email: "tanya.morozova@luminarydesign.co",      phone: "+1-512-555-0187",
    company: luminary,
    notes: "Senior designer at Luminary. Recently promoted. Working on an internal process overhaul that could double their seat count. Mentioned she's frustrated with how their current tools handle version history.",
    tags: [ customer, lead ]
  },
  {
    first_name: "Aiden",    last_name: "Scott",
    email: "aiden.scott@cobaltlabs.io",             phone: "+1-628-555-0133",
    company: cobalt,
    notes: "Backend engineer at Cobalt. Built the initial webhook integration on their side. Very active in our developer Slack community — answered several questions from other customers. Would love to feature him in a developer spotlight.",
    tags: [ customer ]
  },
  {
    first_name: "Rosa",     last_name: "Martinez",
    email: "rosa.martinez@hartwellpartners.com",    phone: "+1-212-555-0144",
    company: hartwell,
    notes: "Business development manager at Hartwell. Manages their partnership pipeline. Exploring a joint go-to-market agreement where they'd resell or co-refer our product to their client base. Early stages.",
    tags: [ partner, prospect ]
  },
  {
    first_name: "Flynn",    last_name: "Cooper",
    email: "flynn.cooper@vantagecapital.vc",        phone: "+1-650-555-0126",
    company: vantage,
    notes: "Investment associate at Vantage. Does the initial due diligence on new opportunities. Young, sharp, and very plugged in to the YC/Sequoia deal flow. Helpful to maintain a warm relationship here.",
    tags: [ investor, lead ]
  },
  # Archived contacts
  {
    first_name: "Patrick",  last_name: "Huang",
    email: "patrick.huang@meridiansoftware.com",    phone: "+1-415-555-0108",
    company: meridian,  archived_at: 2.months.ago,
    notes: "Former VP of Engineering at Meridian. Left the company in November. Was an early champion. His replacement (Ethan Blake) has taken over the technical relationship. Archive — reconnect if Patrick lands somewhere new.",
    tags: [ customer ]
  },
  {
    first_name: "Jasmine",  last_name: "Lee",
    email: "jasmine.lee@cascadeanalytics.io",       phone: "+1-206-555-0117",
    company: cascade,   archived_at: 6.weeks.ago,
    notes: "Former customer success manager at Cascade. She moved to a competitor. Account is now managed by Owen. Archiving since she has no decision-making authority in her new role for our product.",
    tags: [ customer ]
  },
  {
    first_name: "Mike",     last_name: "Thorpe",
    email: "mike.thorpe@outlook.com",               phone: "+1-720-555-0149",
    company: nil,       archived_at: 3.months.ago,
    notes: "Inbound lead from our website in Q3. Had one discovery call — seemed interested in the solo plan. Went dark after the trial expired. Three follow-up emails unanswered. Archiving for now.",
    tags: [ lead ]
  },
  {
    first_name: "Valentina", last_name: "Cruz",
    email: "valentina.cruz@designsprint.co",        phone: "+1-737-555-0165",
    company: nil,       archived_at: 10.weeks.ago,
    notes: "Ran a design sprint facilitation workshop for our team in Q2. Great facilitator. Contract was for a one-time engagement — archiving since there's no active relationship to maintain. Would bring back for future workshops.",
    tags: [ vendor ]
  }
]

contacts = contact_list.map do |attrs|
  contact = Contact.find_or_create_by!(email: attrs[:email]) do |c|
    c.first_name  = attrs[:first_name]
    c.last_name   = attrs[:last_name]
    c.phone       = attrs[:phone]
    c.company     = attrs[:company]
    c.starred     = attrs[:starred] || false
    c.archived_at = attrs[:archived_at]
    c.notes       = attrs[:notes]
  end
  [ contact, attrs[:tags] ]
end
puts "  #{contacts.size} contacts"

# ---------------------------------------------------------------------------
# Tags (assign per contact)
# ---------------------------------------------------------------------------
contacts.each do |(contact, contact_tags)|
  next if contact_tags.blank?
  contact_tags.each do |tag|
    ContactTag.find_or_create_by!(contact: contact, tag: tag)
  end
end
puts "  Tags assigned"

# ---------------------------------------------------------------------------
# Activities (3–5 per contact)
# ---------------------------------------------------------------------------
activity_bodies = {
  "note" => [
    "Discussed enterprise pricing and volume discounts — they're targeting a 50-seat rollout.",
    "Reviewed the security questionnaire together. Two items outstanding: SSO and data residency.",
    "Walked through the Q4 roadmap. Very positive reaction to the workflow automation features.",
    "They flagged a UX issue in the bulk import flow. Logged and prioritized with the product team.",
    "Gave a live demo to two new stakeholders. Good engagement, many questions about the API.",
    "Agreed to co-author a case study. Scheduling a recorded session for next week.",
    "Shared our competitor comparison doc. They're also evaluating HubSpot and Salesforce.",
    "Internal note: champion is strong but legal review is the bottleneck. Escalate to their GC.",
    "Checked in after their product launch — they hit a milestone and are in great spirits.",
    "They requested a custom integration with their BI tool. Flagged to solutions engineering."
  ],
  "call" => [
    "30-minute intro call. Very sharp, asked great questions about data portability and exports.",
    "Quarterly business review. NPS up, usage up 40% YoY. They're happy and looking to expand.",
    "Discovery call — uncovered three key pain points around reporting and team collaboration.",
    "Called to follow up on the contract draft. Legal has one more round of redlines.",
    "20-minute check-in. They're ramping up three new team members and need onboarding help.",
    "Strategic alignment call with their VP and CFO. Strong fit confirmed on both sides.",
    "Called to congratulate them on their Series B announcement. Warm conversation.",
    "Support escalation call — resolved a data sync issue. They were relieved and appreciative.",
    "Year-end review call. Discussed renewal terms and a 15% expansion for Q1.",
    "Quick call to confirm the kickoff date for their enterprise rollout: March 3rd."
  ],
  "email" => [
    "Sent the updated proposal with three tiers and a custom enterprise option.",
    "Forwarded the security and compliance overview deck — covers SOC 2 and GDPR.",
    "Emailed the onboarding guide and intro'd them to their dedicated CSM.",
    "Sent a personalized recap of our conversation with three clear next steps.",
    "Shared the API documentation and a sample integration repo on GitHub.",
    "Emailed the amended contract with data processing agreement attached.",
    "Sent a calendar invite for the exec alignment call — two stakeholders confirmed.",
    "Intro email to connect them with our solutions engineer for a technical deep-dive.",
    "Shared three relevant customer case studies based on their industry and use case.",
    "Followed up with the meeting notes and action items from the kickoff call."
  ]
}

contacts.each do |(contact, _)|
  next if contact.activities.count >= 3
  rand(3..5).times do
    kind = Activity::KINDS.sample
    contact.activities.create!(
      kind:       kind,
      body:       activity_bodies[kind].sample,
      created_at: rand(1..120).days.ago
    )
  end
end
puts "  Activities created"

puts "Done! #{Contact.count} contacts, #{Company.count} companies, #{Tag.count} tags."
