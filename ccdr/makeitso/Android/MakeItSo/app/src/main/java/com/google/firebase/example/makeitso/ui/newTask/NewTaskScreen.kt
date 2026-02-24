package com.google.firebase.example.makeitso.ui.newTask

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Create
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.model.TaskPriority
import com.google.firebase.example.makeitso.ui.theme.DeepDark
import com.google.firebase.example.makeitso.ui.theme.HighlightBlue
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.*

@Serializable
object NewTaskRoute

@Composable
fun NewTaskScreen(
    navigateBack: () -> Unit,
    viewModel: NewTaskViewModel = hiltViewModel()
) {
    NewTaskScreenContent(
        navigateBack = navigateBack,
        onSave = viewModel::saveTask
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewTaskScreenContent(
    navigateBack: () -> Unit = {},
    onSave: (Task, () -> Unit) -> Unit = { _, _ -> }
) {
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var selectedPriority by remember { mutableStateOf(TaskPriority.Medium) }
    var dueDate by remember { mutableStateOf<Date?>(null) }
    
    var showDatePicker by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }

    val datePickerState = rememberDatePickerState()
    val timePickerState = rememberTimePickerState()

    if (showDatePicker) {
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    showDatePicker = false
                    showTimePicker = true
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Cancel") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }

    if (showTimePicker) {
        AlertDialog(
            onDismissRequest = { showTimePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    val calendar = Calendar.getInstance()
                    datePickerState.selectedDateMillis?.let {
                        calendar.timeInMillis = it
                    }
                    calendar.set(Calendar.HOUR_OF_DAY, timePickerState.hour)
                    calendar.set(Calendar.MINUTE, timePickerState.minute)
                    dueDate = calendar.time
                    showTimePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showTimePicker = false }) { Text("Cancel") }
            },
            text = {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    TimePicker(state = timePickerState)
                }
            }
        )
    }

    Scaffold(
        containerColor = if (isSystemInDarkTheme()) DeepDark else Color.White,
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        "Add New Task", 
                        style = MaterialTheme.typography.titleLarge.copy(
                            fontWeight = FontWeight.Bold, 
                            color = if (isSystemInDarkTheme()) Color.White else DeepDark
                        )
                    ) 
                },
                navigationIcon = {
                    IconButton(onClick = navigateBack) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = if (isSystemInDarkTheme()) DeepDark else Color.White
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .padding(horizontal = 24.dp)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            Text(
                "TASK TITLE",
                style = MaterialTheme.typography.labelMedium.copy(color = HighlightBlue, fontWeight = FontWeight.Bold)
            )
            Spacer(modifier = Modifier.height(8.dp))
            TextField(
                value = title,
                onValueChange = { title = it },
                placeholder = { 
                    Text(
                        "What needs to be done?", 
                        style = MaterialTheme.typography.headlineMedium.copy(color = Color.Gray)
                    ) 
                },
                textStyle = MaterialTheme.typography.headlineMedium.copy(
                    color = if (isSystemInDarkTheme()) Color.White else DeepDark
                ),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color(0xFF2B374A),
                    unfocusedIndicatorColor = Color(0xFF2B374A),
                    cursorColor = HighlightBlue
                ),
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(32.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Create, contentDescription = null, tint = Color.Gray, modifier = Modifier.size(16.dp))

                Spacer(modifier = Modifier.width(8.dp))

                Text(
                    "NOTES",
                    style = MaterialTheme.typography.labelMedium.copy(color = Color.Gray, fontWeight = FontWeight.Bold)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            TextField(
                value = description,
                onValueChange = { description = it },
                placeholder = { Text("Add detailed description here...", color = Color.Gray) },
                textStyle = LocalTextStyle.current.copy(color = Color.White),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color(0xFF161F2C),
                    unfocusedContainerColor = Color(0xFF161F2C),
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    cursorColor = Color(0xFF3B82F6)
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp)
            )

            Spacer(modifier = Modifier.height(32.dp))

            Text(
                "PRIORITY LEVEL",
                style = MaterialTheme.typography.labelMedium.copy(color = Color.Gray, fontWeight = FontWeight.Bold)
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                PriorityOption(
                    priority = TaskPriority.Low,
                    selected = selectedPriority == TaskPriority.Low,
                    color = Color(0xFF10B981),
                    onSelect = { selectedPriority = TaskPriority.Low },
                    modifier = Modifier.weight(1f)
                )
                PriorityOption(
                    priority = TaskPriority.Medium,
                    selected = selectedPriority == TaskPriority.Medium,
                    color = Color(0xFFF59E0B),
                    onSelect = { selectedPriority = TaskPriority.Medium },
                    modifier = Modifier.weight(1f)
                )
                PriorityOption(
                    priority = TaskPriority.High,
                    selected = selectedPriority == TaskPriority.High,
                    color = Color(0xFFEF4444),
                    onSelect = { selectedPriority = TaskPriority.High },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        "DUE DATE",
                        style = MaterialTheme.typography.labelMedium.copy(color = Color.Gray, fontWeight = FontWeight.Bold)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    SelectorButton(
                        text = dueDate.toFormattedString(),
                        icon = Icons.Default.DateRange,
                        color = HighlightBlue,
                        onClick = { showDatePicker = true }
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            Button(
                onClick = {
                    val task = Task(
                        title = title,
                        description = description,
                        priority = selectedPriority,
                        dueDate = dueDate
                    )
                    onSave(task, navigateBack)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = HighlightBlue)
            ) {
                Icon(
                    imageVector = Icons.Default.Check,
                    tint = Color.White,
                    contentDescription = null
                )

                Spacer(modifier = Modifier.width(8.dp))

                Text(
                    text = "Save Task",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = Color.White
                )
            }
            
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun PriorityOption(
    priority: TaskPriority, 
    selected: Boolean, 
    color: Color,
    onSelect: () -> Unit,
    modifier: Modifier = Modifier
) {
    val borderColor = if (selected) Color(0xFF3B82F6) else Color(0xFF2B374A)
    
    Surface(
        onClick = onSelect,
        color = Color(0xFF161F2C),
        shape = RoundedCornerShape(12.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
        modifier = modifier.height(48.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(color))

            Spacer(modifier = Modifier.width(8.dp))

            Text(
                text = priority.name,
                style = MaterialTheme.typography.bodyMedium.copy(color = Color.White)
            )
        }
    }
}

@Composable
fun SelectorButton(
    text: String,
    icon: ImageVector,
    color: Color,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        color = Color(0xFF161F2C),
        shape = RoundedCornerShape(12.dp),
        modifier = Modifier.fillMaxWidth().height(48.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(horizontal = 16.dp)
        ) {
            Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(12.dp))
            Text(text, style = MaterialTheme.typography.bodyMedium.copy(color = Color.White), modifier = Modifier.weight(1f))
            Icon(Icons.Default.KeyboardArrowDown, contentDescription = null, tint = Color.Gray)
        }
    }
}

private fun Date?.toFormattedString(): String {
    val formatter = SimpleDateFormat("MMM dd, h:mm a", Locale.getDefault())
    return if (this != null) formatter.format(this) else "No due date"
}

@Preview
@Composable
fun NewTaskScreenPreview() {
    MakeItSoTheme {
        NewTaskScreenContent()
    }
}