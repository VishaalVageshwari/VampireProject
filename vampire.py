from app import create_app, db
from app.models import Blood, RequestedBlood, BloodRequest, BloodOrder, MedicalFacility

app = create_app()


@app.shell_context_processor
def make_shell_context():
    return {
        'db': db, 
        'Blood': Blood,
        'RequestedBlood': RequestedBlood,
        'BloodRequest': BloodRequest,
        'BloodOrder': BloodOrder,
        'MedicalFacility': MedicalFacility
    }