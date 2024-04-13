extends CharacterBody3D

@onready var head_marker = $Mesh/tutorbot/TutorBot/Skeleton3D/BoneAttachment3D/HeadMarker
@onready var retical_point = $ReticalPoint

var looked_at := false
var targeted := false
